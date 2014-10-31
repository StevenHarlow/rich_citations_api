# Copyright (c) 2014 Public Library of Science
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

module Serializer
  module Reference
    def self.included base
      base.extend ::Serializer::ClassMethods
    end

    def to_json(opts = { include_cited: false })
      retval = { 'number'            => self.number,
                 'uri'               => self.uri,
                 'uri_source'        => self.uri_source,
                 'id'                => self.ref_id,
                 'original_citation' => self.original_citation,
                 'accessed_at'       => self.accessed_at,
                 'score'             => self.score,
                 'citation_groups'   => self.citation_groups.map(&:group_id).presence }

      if opts[:include_cited]
        retval.merge!(
          'bib_source'    => self.cited_paper.bib_source,
          'word_count'    => self.cited_paper.word_count,
          'bibliographic' => self.bibliographic)
      end
      retval.compact
    end

    def set_from_json(json)
      uri_raw  = json['uri']
      self.uri = (uri_raw && Helper.normalize_uri(uri_raw)) || random_citation_uri
      self.ref_id = json['id']

      bibliographic = json['bibliographic']

      #@todo We ignore this data for now but should really validate it against paper/citation_groups/references
      cited_paper     = ::Paper.find_by(uri: uri)

      unless cited_paper || bibliographic
        fail "Cannot assign metadata unless the paper exists or bibliographic metadata is provided for #{ref_id}" #@todo
      end

      if bibliographic
        cited_paper ||= ::Paper.new(uri: uri)
        cited_paper.assign_bibliographic_metadata(bibliographic)
      end

      cited_paper.uri_source = json['uri_source']
      cited_paper.bib_source = json['bib_source']
      cited_paper.word_count = json['word_count']

      self.uri               = uri
      self.ref_id            = ref_id
      self.number            = json['number']
      self.original_citation = Helper.sanitize_html(json['original_citation'])
      self.accessed_at       = json['accessed_at']
      self.score             = json['score']
      self.cited_paper       = cited_paper
    end

    def random_citation_uri
      "cited:#{SecureRandom.uuid}"
    end
  end
end
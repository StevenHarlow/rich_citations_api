require 'uri'

class Paper < ActiveRecord::Base
  validates :uri, presence: true
  validate :valid_uri
  has_many :citations, foreign_key: :citing_paper_id
  has_many :citing_papers, through: :citations, class: Paper
  has_many :cited_papers, through: :citations, class: Paper

  def bibliographic
    raw = read_attribute('bibliographic')
    @bibliographic ||= raw && MultiJson.load(raw)
  end

  def bibliographic= value
    @bibliographic = nil
    write_attribute('bibliographic', MultiJson.dump(value) )
  end

  def extended
    raw = read_attribute('extended')
    @extended ||= raw && MultiJson.load(raw)
  end

  def extended= value
    @extended = nil
    write_attribute('extended', MultiJson.dump(value) )
  end

  def metadata(include_cited_paper=false)
    (extended || {}).merge(
      'uri'           => uri,
      'bibliographic' => bibliographic,
      'references'    => citations_metadata(include_cited_paper) #@todo: Should this name match the field name?
    ).compact
  end
  alias :to_json metadata

  def reload
    super
    @bibliographic = nil
    @extended = nil
  end

  private

  def valid_uri
    parsed = URI.parse(uri)
    errors.add(:uri, 'must be a URI') if parsed.scheme.nil?
  rescue URI::InvalidURIError
    errors.add(:uri, 'must be a URI')
  end

  def citations_metadata(include_cited_papers=false)
    return nil if citations.empty?

    citations.map { |c| c.metadata(include_cited_papers) }
  end

end

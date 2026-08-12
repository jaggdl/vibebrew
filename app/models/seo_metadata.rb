class SeoMetadata
  attr_reader :record

  def initialize(record)
    @record = record
  end

  def title
    raise NotImplementedError, "#{self.class} must implement #title"
  end

  def description
    raise NotImplementedError, "#{self.class} must implement #description"
  end

  def og_title
    title.sub(/ \| VibeBrew$/, "")
  end

  def og_type
    "website"
  end

  def og_image
    nil
  end
end

class UmichCatalogItems
  attr_reader :docs
  def self.for(barcodes: [])
    self.new(CatalogSolrClient.client.get_docs_for_barcodes(barcodes))
  end
  def initialize(docs)
    @docs = docs
  end
  def item_for_barcode(barcode)
    Item.new( doc: @docs.find{|doc| doc["barcode"].include?(barcode)}, barcode: barcode)
  end

  class Item
    def initialize(doc:, barcode:)
      @doc = doc
      @barcode = barcode
    end
    def callnumber
      umich_holding_item&.dig("callnumber")
    end
    def mms_id
      @doc["id"]
    end
    def title
      @doc["title_display"]&.first
    end
    def author
      @doc["main_author_display"]&.first
    end
    def oclc
      @doc["oclc"].join("|")
    end
    def description
      umich_holding_item&.dig("description")
    end
    def inventory_number
      umich_holding_item&.dig("inventory_number")
    end
    def umich_holding_item
      @umich_holding_item ||= JSON.parse(@doc["hol"]).filter do |x| 
        !["HathiTrust Digital Library"].include?(x["library"])  
      end&.pluck("items")&.flatten&.find{|y| y["barcode"] == @barcode }
    end
  end
end

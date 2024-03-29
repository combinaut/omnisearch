# encoding: UTF-8
module OmniSearch

  # Fetches a named index
  # ----------------------------------
  # index_class - like DoctorIndex
  # index_type  - like PlainText
  #
  #
  # Usage:
  # ================================================================
  # Indexes::Fetcher.new(SomethingIndex, Indexes::Plaintext)
  #

  class Indexes::Fetcher
    # index_class holds an one of the user configurable classes.
    #  see Indexes::Register, for how an index_class is specified
    attr_accessor :index_class

    # index_type holds the index generator
    # while a plaintext index is straightforward, a trigram index
    # requires the index class to do some work
    attr_accessor :index_type

    #EXPLAIN: Using a class variable as storage is probably not a good choice
    # that means we have a buffer for each instance
    # there is really no way to clear that unless we somehow get inside every passenger instance
    # memcache or redis as options?
    @@buffer ||= {}

    def self.expire_buffer!
      @@buffer = {}
    end

    def initialize(index_class, index_type)
      @index_class = index_class
      @index_type  = index_type
      #EXPLAIN: Do we have to copy the entire buffer every time. Think of the memory!
      @buffer      = @@buffer["#{@index_type}#{@index_class}"]
    end

    def name
      index_class.index_name
    end

    def buffer_save
      @@buffer["#{@index_type}#{@index_class}"] = @records
    end

    def records
      return @buffer if @buffer
      @records ||= load
      buffer_save
      @records
    end

    def storage
      index_type::STORAGE_ENGINE.new(name)
    end

    def load
      @records = storage.load
    end

  end
end

# encoding: UTF-8
module OmniSearch
  class Search::Strategy

    def self.run(term)
      results = ResultSet::Factory.sets(Indexes::Plaintext, Engines::Regex, term, 0)
      if results.empty?
        results = ResultSet::Factory.sets(Indexes::Plaintext, Engines::StringDistance, term, 0.55)
      end
      results
    end

  end
end

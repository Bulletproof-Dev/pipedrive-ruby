module Pipedrive
  class Person < Base

    class << self

      def find_or_create_by_name(name, opts={})
        find_by_name(name, :org_id => opts[:org_id]).first || create(opts.merge(:name => name))
      end

      def search(opts)
        res = get "#{resource_path}/search", query: opts
        res.success? ? res['data'] : bad_response(res,opts)
      end

      def find_by_name(name, opts={})
        res = search({ term: name, fields: "name", exact_match: true }.merge(opts))

        return unless person_id = res.fetch("items", nil)&.first&.fetch("item", nil)&.fetch("id", nil)

        find(person_id)
      end

    end

    def deals()
      Deal.all(get "#{resource_path}/#{id}/deals", :everyone => 1)
    end

    def merge(opts = {})
      res = put "#{resource_path}/#{id}/merge", :body => opts
      res.success? ? res['data'] : bad_response(res,opts)
    end

    def add_follower(opts = {})
      res = post "#{resource_path}/#{id}/followers", :body => opts
      res.success? ? true : bad_response(res,opts)
    end

    def followers
      User.all(get "#{resource_path}/#{id}/followers")
    end

  end
end

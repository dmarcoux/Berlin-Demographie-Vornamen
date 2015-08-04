# TODO Authentication
class BDV_App < Sinatra::Application
    helpers RoutesUtils

    before do
        content_type :json
    end

    before "/names/:id" do |id|
        id = id.to_i

        if id <= 0
            return [400, { message: "Invalid id parameter", description: "A valid Integer greater than 0 must be provided" }.to_json]
        end

        unless @name = Name.find(id: id)
            return [404, { message: "Not found", description: "Name ##{id} doesn't exist" }.to_json]
        end
    end

    # Retrieve a list of names
    get "/names" do
        sanitize_default_params(Name, params)

        name = params[:name]
        count = params[:count]
        gender = params[:gender]
        neighborhood = params[:neighborhood]

        names = DB[:names]
        names = names.filter(name: name) unless name.empty?
        names = names.filter(count: count) unless count <= 0
        names = names.filter(gender: gender) unless gender.empty?
        names = names.filter(neighborhood: neighborhood) unless neighborhood.empty?

        # TODO implement pagination
        [200, names.limit(100).all.to_json]
    end

    # Retrieve a specific name
    get "/names/:id" do
        [200, @name.to_json]
    end

    # Create a new name
    post "/names" do
        sanitize_default_params(Name, params)

        name = Name.new(params)
        if name.save
            # TODO location header for the newly created name...
            [200, name.to_json]
        else
            [422, name.errors.to_json]
        end
    end

    # Update a specific name
    put "/names/:id" do |id|
        sanitize_params(Name, params)

        if params.empty?
            return [400, { message: "Parameters needed", description: "Provide valid parameters to update Name ##{id}" }.to_json]
        end

        unless @name.update(params)
            return [422, @name.errors.to_json]
        end

        [200, @name.to_json]
    end

    # Delete a specific name
    delete "/names/:id" do |id|

    end
end

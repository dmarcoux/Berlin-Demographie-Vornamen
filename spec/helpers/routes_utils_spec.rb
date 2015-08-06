require_relative "../spec_helper"

describe RoutesUtils do
    before do
        @module = Class.new { extend RoutesUtils }

        @model = Class.new(Sequel::Model) do
                    def self.set_columns_sanitization(h)
                        @@columns_sanitization = h
                    end

                    def self.columns_sanitization
                        @@columns_sanitization
                    end
                 end
    end

    describe "#sanitize_params" do
        describe "a model without columns_sanitization, any 'params' hash and any 'all' value" do
            it do
                m = Class.new(Sequel::Model)

                error = proc { @module.sanitize_params(m, {}) }.must_raise NoMethodError
                error.name.must_equal "RoutesUtils.sanitize_params"

                error = proc { @module.sanitize_params(m, { "col1" => "lala", "col2" => "3" }, true) }.must_raise NoMethodError
                error.name.must_equal "RoutesUtils.sanitize_params"
            end
        end

        describe "a model with columns_sanitization" do
            before do
                @model.set_columns_sanitization({ col1: :to_i, col2: :to_s })

                # Using String keys to simulate Sinatra params hash
                @params = { "col1" => "123", "col3" => "Derp" }
            end

            describe "and no allowed columns" do
                it { @module.sanitize_params(@model, @params).must_be_empty }

                describe "with the argument 'all' set to true" do
                    it { @module.sanitize_params(@model, @params, true).must_be_empty }
                end
            end

            describe "and allowed columns" do
                before do
                    @model.set_allowed_columns(:col1, :col2)
                end

                it "returns the sanitized allowed columns which were present in the 'params' hash" do
                    @module.sanitize_params(@model, @params).must_equal ({ col1: 123 })
                end

                describe "with the argument 'all' set to true" do
                    it "returns all the sanitized allowed columns and the ones who were missing, have their type's default value" do
                        @module.sanitize_params(@model, @params, true).must_equal ({ col1: 123, col2: "" })
                    end
                end
            end
        end
    end

    describe "#sanitize_limit_param" do
        describe "when receiving nil or a String which converted to Integer equals 0" do
            it "returns 100" do
                @module.sanitize_limit_param(nil).must_equal 100
                @module.sanitize_limit_param("Foo").must_equal 100
            end
        end

        describe "when receiving a String which converted to Integer is between 1 and 100" do
            it "returns the newly converted Integer" do
                1.upto(100) do |n|
                    @module.sanitize_limit_param(n.to_s).must_equal n
                end
            end
        end

        describe "when receiving a String which converted to Integer is greater than 100" do
            it "returns 100" do
                @module.sanitize_limit_param("101").must_equal 100
            end
        end
    end

    describe "#sanitize_offset_param" do
        describe "when receiving nil or a String which converted to Integer equals 0" do
            it "returns 0" do
                @module.sanitize_offset_param(nil).must_equal 0
                @module.sanitize_offset_param("Foo").must_equal 0
            end
        end

        describe "when receiving a String which converted to Integer is smaller than 0" do
            it "returns 0" do
                @module.sanitize_offset_param("-1").must_equal 0
            end
        end

        describe "when receiving a String which converted to Integer is greater than 0" do
            it "returns the newly converted Integer" do
                @module.sanitize_offset_param("1").must_equal 1
                @module.sanitize_offset_param("1000").must_equal 1000
            end
        end
    end
end
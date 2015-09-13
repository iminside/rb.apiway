module Apiway

  def self.path
    @gem_path ||= File.expand_path '..', File.dirname( __FILE__ )
  end

end

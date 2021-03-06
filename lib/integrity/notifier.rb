module Integrity
  class Notifier
    include DataMapper::Resource

    property :id,      Serial
    property :name,    String,   :required => true
    property :enabled, Boolean,  :required => true, :default => false
    property :config,  Yaml,     :required => true, :lazy    => false

    belongs_to :project

    validates_uniqueness_of :name, :scope => :project

    def self.available
      @notifiers ||= {}
    end

    def self.register(klass)
      available[klass.to_s.split(":").last] = klass
    end

    def notify(build)
      klass && klass.notify(build, config)
    end

    def klass
      self.class.available[name]
    end

    def notify_of_build_start(build)
      klass.notify_of_build_start(build, config) if klass
    end
  end
end

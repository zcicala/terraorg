require 'faraday'

class Person
  ACTIVE_USER_STATUSES = ['ACTIVE', 'PROVISIONED'].freeze

  attr_accessor :id, :name, :okta_id, :email, :status

  def initialize(uid, okta: nil, cached: nil)
    @id = uid

    if cached
      @name = cached.fetch('name')
      @okta_id = cached.fetch('okta_id')
      @email = cached.fetch('email')
      @status = cached.fetch('status')

      return
    elsif !okta
      # We could just be running in fmt mode, so lie about everything
      @name = "real name of #{@id}"
      @okta_id = "fake okta id for #{@id}"
      @email = "#{@id}@my.domain"
      @status = 'PROVISIONED'

      return
    end

    # Retrieve from okta
    tries = 1
    total_tries = 5

    begin
      o = okta.get_user(uid)
    rescue Faraday::ConnectionFailed => e
      if tries <= total_tries
        puts "looking up user #{uid}: #{e} (try #{tries}/#{total_tries})"
        tries += 1
        retry
      end
      raise
    end

    if tries > 1
      puts "looking up user #{uid}: success!"
    end

    # NOTE: allows users in states other than ACTIVE
    # if you want to check that, do it outside of here
    obj = o[0].to_hash
    @name = obj.fetch(:profile).fetch(:displayName)
    @okta_id = obj.fetch(:id)
    @email = obj.fetch(:profile).fetch(:email)
    @status = obj.fetch(:status)
  end

  def active?
    ACTIVE_USER_STATUSES.member?(@status)
  end

  def to_json(options = nil)
    {'id' => @id, 'name' => @name, 'okta_id' => @okta_id, 'email' => @email, 'status' => @status}.to_json
  end
end

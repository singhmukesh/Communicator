class Admin

  attr_accessor :id
  attr_accessor :name
  attr_accessor :password

  @@secret = "a secret admin"

  def initialize(id, name, password)
    @id = id
    @name = name
    @password = password
  end

  # Make a single instance of the admin.  ADMIN_PASSWORD is top-level global var from env vars.
  @@singleton = Admin.new(0, "admin", ADMIN_PASSWORD)

  # Our authentication scheme returns the admin
  def self.authenticate(name, password)
    admin = @@singleton
    if @@singleton.name != name or @@singleton.password != password
      admin = nil
    end
    admin
  end

  # Find the admin by its id
  def self.find_by_id(id)
    if @@singleton.id == id
      @@singleton
    else
      nil
    end
  end
    
end

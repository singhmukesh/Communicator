#
# Interface to the RTCC ReST API v2.0
#
# Endpoints:
#    usertoken(uid, domain, profile)
#

class RTCCClient

  @@baseurl = "https://api.rtccloud.net/v2.0/provider"

  #
  # The client is initialized with the ID and SECRET
  #

  def initialize(client_id, client_secret)

    @apikey = "#{client_id}#{client_secret}"  # concatenation of the two

  end


  #
  # The token endpoint returns a single-use token to connect to the RealTime cloud
  #

  def usertoken(uid, domain, profile)

    params = {
      :uid => uid,
      :domain => domain,
      :profile => profile
    }

    response = RestClient.post("#{@@baseurl}/usertoken", params, 'authorization' => "Apikey #{@apikey}")
    jdata = JSON.parse(response.body)

  end


end

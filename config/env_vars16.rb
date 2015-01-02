# This file is not checked into GIT

# Path to the Weemo CA Cert
# ENV['RTCC_CACERT'] = "/Users/sheffler/weemo/certs/wauth9/weemo-ca.pem"
ENV['RTCC_CACERT'] = "/Users/sheffler/sightcall/certs/wauth16/authCA.crt"
# ENV['RTCC_CACERT'] = "/home/wimoadmin/certs/wauth9/weemo-ca.pem"

# Paths to the extracted key and cert from the client.p12 file
# ENV['RTCC_CLIENTCERT'] = "/Users/sheffler/weemo/certs/wauth9/publicCert.pem"
ENV['RTCC_CLIENTCERT'] = "/Users/sheffler/sightcall/certs/wauth16/publicCert.pem"
# ENV['RTCC_CLIENTCERT'] = "/home/wimoadmin/certs/wauth9/publicCert.pem"
# ENV['RTCC_CLIENTCERT_KEY'] = "/Users/sheffler/weemo/certs/wauth9/privateKey.pem"
ENV['RTCC_CLIENTCERT_KEY'] = "/Users/sheffler/sightcall/certs/wauth16/privateKey.pem"
# ENV['RTCC_CLIENTCERT_KEY'] = "/home/wimoadmin/certs/wauth9/privateKey.pem"

# Password
ENV['RTCC_CERTPASSWORD'] = "XnyexbUF"

# Weemo Auth endpoint, Client ID and Secret
ENV['RTCC_AUTH_URL'] = "https://auth.rtccloud.net/auth/"
ENV['RTCC_CLIENT_ID'] = "6uanat9urpzuujdgeu1h0hj2huesnd"
ENV['RTCC_CLIENT_SECRET'] = "wka0hhv8skwqi1yohqo27y4qsnss3x"

# For the front end
ENV['RTCC_APP_ID'] = "4wsd70clgrup"

# For the cloudrecorder
ENV['CLOUDRECORDER_TOKEN'] = "7e59b98c27331b82ef0e8fa9bfe37fcb" # production (rds postgres 9.3.3)

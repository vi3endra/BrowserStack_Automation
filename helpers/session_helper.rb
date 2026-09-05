module SESSION_HELPER

    $HOST_URL = "https://bugbash.online/"
    $HOST_DOMAIN = "bugbash.online"

    def self.visit_url url
        $driver.navigate.to url
        puts "Successfully navigated to: #{url}"
    end

    def self.add_cookies_to_skip_cpatcha host_url
        $driver.manage.add_cookie(
        name: "skip_captcha_for_testing", 
        value: "true", 
        domain: host_url,
        path: "/"
        )
    end
end
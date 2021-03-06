require "spec_helper"

describe DiscourseSingleSignOn do
  before do
    @sso_url = "http://somesite.com/discourse_sso"
    @sso_secret = "shjkfdhsfkjh"

    SiteSetting.enable_sso = true
    SiteSetting.sso_url = @sso_url
    SiteSetting.sso_secret = @sso_secret
  end

  def make_sso
    sso = SingleSignOn.new
    sso.sso_url = "http://meta.discorse.org/topics/111"
    sso.sso_secret = "supersecret"
    sso.nonce = "testing"
    sso.email = "some@email.com"
    sso.username = "sam"
    sso.name = "sam saffron"
    sso.external_id = "100"
    sso.custom_fields["a"] = "Aa"
    sso.custom_fields["b.b"] = "B.b"
    sso
  end

  def test_parsed(parsed, sso)
    expect(parsed.nonce).to eq sso.nonce
    expect(parsed.email).to eq sso.email
    expect(parsed.username).to eq sso.username
    expect(parsed.name).to eq sso.name
    expect(parsed.external_id).to eq sso.external_id
    expect(parsed.custom_fields["a"]).to eq "Aa"
    expect(parsed.custom_fields["b.b"]).to eq "B.b"
  end

  it "can do round trip parsing correctly" do
    sso = SingleSignOn.new
    sso.sso_secret = "test"
    sso.name = "sam saffron"
    sso.username = "sam"
    sso.email = "sam@sam.com"

    sso = SingleSignOn.parse(sso.payload, "test")

    expect(sso.name).to eq "sam saffron"
    expect(sso.username).to eq "sam"
    expect(sso.email).to eq "sam@sam.com"
  end

  it "can lookup or create user when name is blank" do
    # so we can create system messages
    Fabricate(:admin)
    sso = DiscourseSingleSignOn.new
    sso.username = "test"
    sso.name = ""
    sso.email = "test@test.com"
    sso.external_id = "A"
    user = sso.lookup_or_create_user
    expect(user).to_not be_nil
  end

  it "can fill in data on way back" do
    sso = make_sso

    url, payload = sso.to_url.split("?")
    expect(url).to eq sso.sso_url
    parsed = SingleSignOn.parse(payload, "supersecret")

    test_parsed(parsed, sso)
  end

  it "handles sso_url with query params" do
    sso = make_sso
    sso.sso_url = "http://tcdev7.wpengine.com/?action=showlogin"

    expect(sso.to_url.split('?').size).to eq 2

    url, payload = sso.to_url.split("?")
    expect(url).to eq "http://tcdev7.wpengine.com/"
    parsed = SingleSignOn.parse(payload, "supersecret")

    test_parsed(parsed, sso)
  end

  it "validates nonce" do
    _ , payload = DiscourseSingleSignOn.generate_url.split("?")

    sso = DiscourseSingleSignOn.parse(payload)
    expect(sso.nonce_valid?).to eq true

    sso.expire_nonce!

    expect(sso.nonce_valid?).to eq false

  end

  it "generates a correct sso url" do

    url, payload = DiscourseSingleSignOn.generate_url.split("?")
    expect(url).to eq @sso_url

    sso = DiscourseSingleSignOn.parse(payload)
    expect(sso.nonce).to_not be_nil
  end
end

require 'net/http'

RSpec.describe MailerService::ExternalMailerService do

  let(:asset_host) { "http://localhost.com:3000" }
  let(:person_sender) { create(:person, fname:"test sender") }
  let(:company) { create(:company) }
  let(:sender_email) { create(:email, address:"das1@sda.com") }
  let(:sender_member) { Member.create(person:person_sender, email:sender_email) }

  let(:job) { create(:job, company:company) }

  let(:person_recipient) { create(:person, fname:"test sender") }

  let(:recipient_email) { create(:email, address:"das2@sda.com") }
  let(:recipient_member) { Member.create(person: person_recipient, email:recipient_email ) }

  let(:unsubscribe_url) { 'https://api.test.com' }

  let(:locals) do
    {
    :@sharer => sender_member,
    :@job => job,
    :@member => recipient_member,
    :@host => 'localhost',
    :@asset_host => asset_host,
    :@unsubscribe_url => unsubscribe_url,
    :@msg => nil
    }
  end

  let(:single_tag) { ['share_job_' + job.id.to_s + '_' + '2020-12-21 17:54:01 +0000'] }

  let(:valid_params) do
    [
      person_sender.fname,
      sender_email.address,
      person_recipient.fname,
      recipient_email.address,
      recipient_email.id,
      subject,
      'member_mailer/share_job',
      locals,
      single_tag
    ]
  end

  let(:invalid_params) do
    [
      person_sender.fname,
      sender_email.address,
      person_recipient.fname,
      recipient_email.address,
      recipient_email.id,
      subject,
      'member_mailer/share_job',
      locals,
      'sdasdasd'
    ]
  end

  let(:subject) { "random subject" }

  describe ".ancestors" do
    it 'extends from BaseExternalMailerService' do
      expect(described_class.ancestors).to include(MailerService::BaseExternalMailerService)
    end
  end

  describe "#perform" do

  context "and parameters are correct" do
    let(:service) do
      described_class.new(*valid_params)
    end

    before do
      allow_any_instance_of(Net::HTTP).to receive(:request) do
        OpenStruct.new({
          :body => "{\"message\":\"Email scheduled to be sent\",\"amount\":1}",
          :code => "202"
        })
      end
      @result = service.perform
    end

    it 'expects the body to be correctly created' do
      expect(@result[:body]).to match(expected_body)
    end

    it 'expects the new e-mail send request to be successful' do
        expect(@result[:response_body]).to eq("{\"message\":\"Email scheduled to be sent\",\"amount\":1}")
      end
    end
  end

  context "and parameters are not correct. remote server rejects request" do
    let(:service) do
      described_class.new(*invalid_params)
    end

    before do
      expect_any_instance_of(SystemMailer).to receive(:error_on_server)
    end

    it "sends an e-mail to devops-monitoring@jobspeaker.com" do
      service.perform
    end
  end

  def expected_body
    {
      "from": { "name": "test sender", "email": "das1@sda.com" },
      "to": { "name": "test sender", "email": "das2@sda.com" },
      "subject": "random subject",
      "text": "Hello test sender Doe!\n  \ntest sender Doe has recommended the job '' at  to you!\n \n\n\n\u003ca href=\"localhost/#/\"\u003eLog in\u003c/a\u003e to your My Jobs dashboard where this job has been listed.\n\nThank you!\n\nThe Jobspeaker Team.\n",
      "html": "\u003c!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\"\u003e\n\u003chtml xmlns=\"http://www.w3.org/1999/xhtml\"\u003e\n  \u003chead\u003e\n    \u003cmeta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" /\u003e\n    \u003cmeta name=\"viewport\" content=\"width=device-width\"/\u003e\n\n    \u003cstyle type=\"text/css\"\u003e\n      * {\n\tmargin: 0;\n\tpadding: 0;\n\tfont-size: 13px;\n\tfont-family: 'Avenir Next', \"Helvetica Neue\", \"Helvetica\", Helvetica, Arial, sans-serif;\n\tline-height: 1.65; }\n\n      img {\n\tmax-width: 100%;\n\tmargin: 0 auto;\n\tdisplay: block; }\n\n      body,\n      .body-wrap {\n\twidth: 100% !important;\n\theight: 100%;\n\tbackground: #efefef;\n\t-webkit-font-smoothing: antialiased;\n\t-webkit-text-size-adjust: none; }\n\n      a {\n\tcolor: #97b83e; }\n\n      .text-center {\n\ttext-align: center; }\n\n      .text-right {\n\ttext-align: right; }\n\n      .text-left {\n\ttext-align: left; }\n\n      .button {\n\tdisplay: inline-block;\n\tcolor: white;\n\tbackground: #71bc37;\n\tborder: solid #71bc37;\n\tborder-width: 10px 20px 8px;\n\tfont-weight: bold;\n\tborder-radius: 4px; }\n\n      h1, h2, h3, h4, h5, h6 {\n\tmargin-bottom: 20px;\n\tline-height: 1.25; }\n\n      h1 {\n\tfont-size: 32px; }\n\n      h2 {\n\tfont-size: 28px; }\n\n      h3 {\n\tfont-size: 24px; }\n\n      h4 {\n\tfont-size: 20px; }\n\n      h5 {\n\tfont-size: 16px; }\n\n      p, ul, ol {\n\tfont-size: 13px;\n\tfont-weight: normal;\n\tmargin-bottom: 20px; }\n\n      .container {\n\tdisplay: block !important;\n\tclear: both !important;\n\tmargin: 0 auto !important;\n\tmax-width: 580px !important; }\n      .container table {\n\twidth: 100% !important;\n\tborder-collapse: collapse; }\n      .container .masthead {\n  background-color:#fff;\n\theight: 100px;\n\tborder-bottom: 2px solid #ccc;\n\ttext-align:left;}\n\n      .container .masthead .social {\n  margin-right:10px;\n  margin-bottom:0;\n  }          \n      .container .masthead .logo {\n  width:220px;\n  margin:0 10px;\n  }\n  \n      .container .masthead h1 {\n\tmargin: 0 auto !important;\n\tmax-width: 90%;\n\ttext-transform: uppercase; }\n      .container .content {\n\tbackground: white;\n\tpadding: 30px 35px; }\n      .container .content.footer {\n  background: rgba(0, 0, 0, 0) url(\"http://localhost.com:3000/mail_img/brushed_alu.png\") repeat scroll 0 0;\n\theight: 80px;\n\tpadding: 0px;\n }\n      .container .content.footer p {\n        margin-bottom: 0;\n        color: #888;\n        text-align: center;\n        font-size: 13px; }\n      .container .content.footer a {\n        color: #888;\n        text-decoration: none;\n        font-weight: bold; }\n      .preheader {\n        display:none !important;\n        visibility:hidden;\n        opacity:0;\n        color:transparent;\n        height:0;\n        width:0; }\n\n    \u003c/style\u003e\n  \u003c/head\u003e\n\n  \u003cspan class=\"preheader\" style=\"display: none !important; visibility: hidden; opacity: 0; color: transparent; height: 0; width: 0;\"\u003e\n      \n  \u003c/span\u003e\n\n  \u003cbody\u003e\n    \u003ctable class=\"body-wrap\"\u003e\n      \u003ctr\u003e\n        \u003ctd class=\"container\"\u003e\n          \u003ctable\u003e\n            \u003ctr\u003e\n              \u003ctd class=\"masthead\"\u003e\n                \u003ctable height=\"100%\"\u003e\n                  \u003ctr\u003e\n                    \u003ctd valign=\"middle\"\u003e\u003cimg src=\"http://localhost.com:3000/mail_img/logo_dark.png\" class='logo' alt=\"Jobspeaker\"/\u003e\u003c/td\u003e\n                    \u003ctd valign=\"bottom\" style='text-align:right;padding-right:10px;'\u003e\n                      \u003ca href=\"https://twitter.com/jobspeaker\" style=\"display:inline-block\"\u003e\u003cimg src=\"http://localhost.com:3000/mail_img/dark-twitter.png\" class='social' alt=\"Twitter\"/\u003e\u003c/a\u003e\n                      \u003ca href=\"https://www.facebook.com/jobspeaker\" style=\"display:inline-block\"\u003e\u003cimg src=\"http://localhost.com:3000/mail_img/dark-facebook.png\" class='social' alt=\"Facebook\"/\u003e\u003c/a\u003e\n                      \u003ca href=\"https://www.linkedin.com/company/jobspeaker\" style=\"display:inline-block\"\u003e\u003cimg src=\"http://localhost.com:3000/mail_img/dark-linkedin.png\" class='social' alt=\"LinkedIn\"/\u003e\u003c/a\u003e\n                    \u003c/td\u003e\n                  \u003c/tr\u003e\n                  \u003ctr\u003e\n                    \u003ctd colspan=\"2\" style=\"padding-left: 10px;\"\u003e\u003ci\u003eBridging the gap between Education and Employment\u003c/i\u003e\u003c/td\u003e\n                  \u003c/tr\u003e\n                \u003c/table\u003e\n              \u003c/td\u003e\n            \u003c/tr\u003e\n            \u003ctr\u003e\n              \u003ctd class=\"content\"\u003e\n\t\t            \u003ch2\u003eHello test sender Doe!\u003c/h2\u003e\n  \n\u003cp\u003e\n  test sender Doe has recommended the job ''to you!\n\u003c/p\u003e\n\n\u003cp\u003e\n  \n\u003c/p\u003e\n  \n\u003cp\u003e\n  \u003ca href=\"localhost/#/\"\u003eLog in\u003c/a\u003e to your My Jobs dashboard where this job has been listed.\n\u003c/p\u003e\n\n\n\u003cp\u003eThank you!\u003c/p\u003e\n\n\u003cp\u003eThe Jobspeaker Team.\u003c/p\u003e\t\t\t\t\t\t\t\t\n              \u003c/td\u003e\n            \u003c/tr\u003e\n          \u003c/table\u003e\n\n        \u003c/td\u003e\n      \u003c/tr\u003e\n      \u003ctr\u003e\n        \u003ctd class=\"container\"\u003e\n\n          \u003ctable\u003e\n            \u003ctr\u003e\n              \u003ctd class=\"content footer\" align=\"center\"\u003e\n                \u003cp\u003e\u003ca href=\"https://www.jobspeaker.com/\"\u003eJobspeaker, Inc\u003c/a\u003e, 126 West Portal Ave., San Francisco, CA 94116\u003c/p\u003e\n\u003cp\u003ePlease do not reply to this email. This mailbox is not monitored and you will not receive a response. For assistance contact Jobspeaker support at \u003ca href=\"mailto:support@jobspeaker.com\"\u003esupport@jobspeaker.com\u003c/a\u003e. To unsubscribe from this email click \u003ca href=\"https://api.test.com\"\u003eUnsubscribe\u003c/a\u003e.\u003c/p\u003e\n              \u003c/td\u003e\n            \u003c/tr\u003e\n          \u003c/table\u003e\n        \u003c/td\u003e\n      \u003c/tr\u003e\n    \u003c/table\u003e\n  \u003c/body\u003e\n\u003c/html\u003e\n\n",
      "attachments": [],
      "tags": ["share_job_1_2020-12-21 17:54:01 +0000"],
      "externalId": "2"
    }
  end
end
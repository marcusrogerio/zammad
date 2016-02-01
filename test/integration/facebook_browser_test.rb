# encoding: utf-8
require 'browser_test_helper'

class FacebookBrowserTest < TestCase
  def test_add_config

    # app config
    if !ENV['FACEBOOK_BT_APP_ID']
      fail "ERROR: Need FACEBOOK_BT_APP_ID - hint FACEBOOK_BT_APP_ID='1234'"
    end
    app_id = ENV['FACEBOOK_BT_APP_ID']
    if !ENV['FACEBOOK_BT_APP_SECRET']
      fail "ERROR: Need FACEBOOK_BT_APP_SECRET - hint FACEBOOK_BT_APP_SECRET='1234'"
    end
    app_secret = ENV['FACEBOOK_BT_APP_SECRET']
    if !ENV['FACEBOOK_BT_USER_LOGIN']
      fail "ERROR: Need FACEBOOK_BT_USER_LOGIN - hint FACEBOOK_BT_USER_LOGIN='1234'"
    end
    user_login = ENV['FACEBOOK_BT_USER_LOGIN']
    if !ENV['FACEBOOK_BT_USER_PW']
      fail "ERROR: Need FACEBOOK_BT_USER_PW - hint FACEBOOK_BT_USER_PW='1234'"
    end
    user_pw = ENV['FACEBOOK_BT_USER_PW']
    if !ENV['FACEBOOK_BT_PAGE_ID']
      fail "ERROR: Need FACEBOOK_BT_PAGE_ID - hint FACEBOOK_BT_PAGE_ID='1234'"
    end
    page_id = ENV['FACEBOOK_BT_PAGE_ID']

    if !ENV['FACEBOOK_BT_CUSTOMER']
      fail "ERROR: Need FACEBOOK_BT_CUSTOMER - hint FACEBOOK_BT_CUSTOMER='name:1234:access_token'"
    end
    customer_name = ENV['FACEBOOK_BT_CUSTOMER'].split(':')[0]
    customer_id = ENV['FACEBOOK_BT_CUSTOMER'].split(':')[1]
    customer_access_token = ENV['FACEBOOK_BT_CUSTOMER'].split(':')[2]

    @browser = browser_instance
    login(
      username: 'master@example.com',
      password: 'test',
      url: browser_url,
      auto_wizard: true,
    )
    tasks_close_all()

    click(css: 'a[href="#manage"]')
    click(css: 'a[href="#channels/facebook"]')

    click(css: '#content .js-configApp')
    sleep 2
    set(
      css: '#content .modal [name=application_id]',
      value: app_id,
    )
    set(
      css: '#content .modal [name=application_secret]',
      value: 'wrong',
    )
    click(css: '#content .modal .js-submit')

    watch_for(
      css: '#content .modal .alert',
      value: 'Error',
    )

    set(
      css: '#content .modal [name=application_secret]',
      value: app_secret,
    )
    click(css: '#content .modal .js-submit')

    watch_for_disappear(
      css: '#content .modal .alert',
      value: 'Error',
    )

    watch_for(
      css: '#content .js-new',
      value: 'add account',
    )

    click(css: '#content .js-configApp')

    set(
      css: '#content .modal [name=application_secret]',
      value: 'wrong',
    )
    click(css: '#content .modal .js-submit')

    watch_for(
      css: '#content .modal .alert',
      value: 'Error',
    )

    set(
      css: '#content .modal [name=application_secret]',
      value: app_secret,
    )
    click(css: '#content .modal .js-submit')

    watch_for_disappear(
      css: '#content .modal .alert',
      value: 'Error',
    )

    watch_for(
      css: '#content .js-new',
      value: 'add account',
    )

    click(css: '#content .js-new')

    watch_for(
      css: 'body',
      value: '(Facebook Login|Log into Facebook)',
    )

    set(
      css: '#email',
      value: user_login,
    )
    set(
      css: '#pass',
      value: user_pw,
    )
    click(css: '#login_button_inline')

    #sleep 10
    #click(css: 'div[role="dialog"] button[type="submit"][name="__CONFIRM__"]')
    #sleep 10
    #click(css: 'div[role="dialog"] button[type="submit"][name="__CONFIRM__"]')
    #sleep 10

    #watch_for(
    #  css: '#content .modal',
    #  value: '',
    #)

    watch_for(
      css: '#navigation',
      value: 'Dashboard',
    )

    select(css: '#content .modal [name="pages::' + page_id + '::group_id"]', value: 'Users')
    click(css: '#content .modal .js-submit')
    sleep 5

    watch_for(
      css: '#content',
      value: 'Hansi Merkur',
    )
    exists(
      css: '#content .main .action:nth-child(1)'
    )
    exists_not(
      css: '#content .main .action:nth-child(2)'
    )

    click(css: '#content .js-new')

    sleep 10

    #click(css: '#login_button_inline')

    #watch_for(
    #  css: '#content .modal',
    #  value: 'Search Terms',
    #)

    click(css: '#content .modal .js-close')

    watch_for(
      css: '#content',
      value: 'Hansi Merkur',
    )
    exists(
      css: '#content .main .action:nth-child(1)'
    )
    exists_not(
      css: '#content .main .action:nth-child(2)'
    )
    sleep 50

    # post new posting
    hash = "##{rand(999_999)}"
    customer_client = Koala::Facebook::API.new(customer_access_token)
    message         = "I need some help for your product #{hash}"
    post            = customer_client.put_wall_post(message, {}, page_id)

    # watch till post is in app
    click( text: 'Overviews' )

    # enable full overviews
    execute(
      js: '$(".content.active .sidebar").css("display", "block")',
    )

    click( text: 'Unassigned & Open' )
    sleep 6 # till overview is rendered

    watch_for(
      css: '.content.active',
      value: hash,
      timeout: 40,
    )

    ticket_open_by_title(
      title: hash,
    )
    click( css: '.content.active [data-type="facebookFeedReply"]' )
    sleep 2

    re_hash = "#{hash}re#{rand(99_999)}"

    ticket_update(
      data: {
        body: "You need to do this #{re_hash} #{rand(999_999)}",
      },
    )
    sleep 20

    match(
      css: '.content.active .ticket-article',
      value: re_hash,
    )

  end

end
require File.expand_path('../../test_helper', __FILE__)

class SchedulingPollsControllerTest < ActionController::TestCase
  fixtures :users, :issues, :projects, :roles,
    :scheduling_polls, :scheduling_poll_items, :scheduling_votes

  def setup
    User.current = User.find(2)
    @request.session[:user_id] = User.current.id
    Project.find(1).enable_module! :scheduling_polls
    Role.find(4).add_permission! :view_schduling_polls
    Role.find(4).add_permission! :vote_schduling_polls
  end

  test "new" do
    get :new, :issue => 1
    assert_redirected_to :action => :show, :id => SchedulingPoll.find(1)

    assert SchedulingPoll.find(1).destroy
    get :new, :issue => 1
    assert_response :success
    assert_template :edit
  end

  test "create" do
    poll = SchedulingPoll.find_by(:issue => 1)
    assert_not_nil poll
    post :create, :scheduling_poll => {:issue_id => 1, :scheduling_poll_item_attributes => []}
    assert_redirected_to :action => :show, :id => SchedulingPoll.find_by(:issue => Issue.find(1))
    assert_nil flash[:notice]

    assert poll.destroy
    poll = nil
    post :create, :scheduling_poll => {:issue_id => 1, :scheduling_poll_item_attributes => [{:text => "text1"}, {:text => "text2"}, {:text => ""}]}
    poll = SchedulingPoll.find_by(:issue => 1)
    assert_not_nil poll
    assert_equal ["text1", "text2"], poll.scheduling_poll_item.map {|v| v.text }
    assert_redirected_to :action => :show, :id => poll
    assert_not_nil flash[:notice]
  end

  test "edit" do
    get :edit, :id => 1
    assert_response :success
    assert_template :edit
  end

  test "update" do
    poll = SchedulingPoll.find_by(:issue => 1)
    assert_not_nil poll
    patch :update, :id => 1, :scheduling_poll => {:issue_id => 1, :scheduling_poll_item_attributes => [{:id => 2, :_destroy => 1}, {:id => 3, :_destroy => 0}, {:text => "text"}, {:text => ""}]}
    assert_equal "text", SchedulingPollItem.last.text
    assert_equal [SchedulingPollItem.find(1), SchedulingPollItem.find(3), SchedulingPollItem.last], poll.scheduling_poll_item.to_a
    assert_redirected_to :action => :show, :id => SchedulingPoll.find_by(:issue => Issue.find(1))
    assert_not_nil flash[:notice]
  end

  test "show" do
    get :show, :id => 1
    assert_response :success
    assert_template :show
  end
end
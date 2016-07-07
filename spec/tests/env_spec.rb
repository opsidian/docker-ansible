require "serverspec"
require "docker"

set :backend, :docker

describe "Dockerfile" do
  before(:all) do
    @container = Docker::Container.create(
      :Image => ENV['DOCKER_IMAGE_NAME'] + ':' + ENV['DOCKER_IMAGE_TAG'],
      :Tty => true,
      :Cmd => 'bash'
    )
    @container.start
    set :docker_container, @container.id
  end

  describe command('pwd') do
    its(:stdout) { should eq "/var/project\n" }
  end

  describe file('/var/project') do
    it { should be_directory }
    it { should be_mode 770 }
    it { should be_owned_by 'app' }
    it { should be_writable.by_user('app') }
  end

  after(:all) do
    if !@container.nil?
      @container.delete(:force => true)
    end
  end
end

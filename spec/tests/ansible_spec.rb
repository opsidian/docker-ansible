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

  describe package('ansible') do
    it { should be_installed.by('pip').with_version('2.1.0.0') }
  end

  describe command('ansible --version') do
    its(:exit_status) { should eq 0 }
  end

  describe package('docker-py') do
    it { should be_installed.by('pip') }
  end

  describe package('boto') do
    it { should be_installed.by('pip') }
  end

  describe file('/etc/ansible/ansible.cfg') do
    it { should be_file }
    it { should be_readable.by_user('app') }
  end

  after(:all) do
    if !@container.nil?
      @container.delete(:force => true)
    end
  end
end

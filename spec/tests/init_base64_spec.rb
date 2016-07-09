require "serverspec"
require "docker"
require "base64"

set :backend, :docker

describe "Dockerfile" do
  before(:all) do
    @container = Docker::Container.create(
      'Image' => ENV['DOCKER_IMAGE_NAME'] + ':' + ENV['DOCKER_IMAGE_TAG'],
      'Tty' => true,
      'Cmd' => 'bash',
      'Env' => [
        'ANSIBLE_SSH_PRIVATE_KEY=base64:' + Base64.encode64(File.read('spec/rsc/test-ssh-private-key')),
      ]
    )
    @container.start
    set :docker_container, @container.id
  end

  describe file('/var/project/ansible-ssh-private-key') do
    it { should be_file }
    it { should be_mode 400 }
    it { should be_owned_by 'app' }
    its(:content) { should eq File.read('spec/rsc/test-ssh-private-key') }
  end

  after(:all) do
    if !@container.nil?
      @container.delete(:force => true)
    end
  end
end

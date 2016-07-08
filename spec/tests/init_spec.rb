require "serverspec"
require "docker"

set :backend, :docker

describe "Dockerfile" do
  before(:all) do
    @container = Docker::Container.create(
      'Image' => ENV['DOCKER_IMAGE_NAME'] + ':' + ENV['DOCKER_IMAGE_TAG'],
      'Tty' => true,
      'Cmd' => 'bash',
      'Env' => [
        'ANSIBLE_SSH_PRIVATE_KEY=' + File.read('spec/rsc/test-ssh-private-key'),
        'ANSIBLE_VAULT_KEY=ansible_vault_key_test'
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

  describe process('ssh-agent') do
    it { should be_running }
    its(:user) { should eq "root" }
  end

  describe command('bash -l -c \'echo $SSH_AGENT_PID\'') do
    its(:stdout) { should match '\d+' }
  end

  describe command('bash -l -c \'echo $SSH_AUTH_SOCK\'') do
    its(:stdout) { should match '/tmp/ssh-.*/agent\.\d+' }
  end

  describe file('/var/project/ansible-vault-key') do
    it { should be_file }
    it { should be_mode 400 }
    it { should be_owned_by 'app' }
    its(:content) { should eq 'ansible_vault_key_test' }
  end

  after(:all) do
    if !@container.nil?
      @container.delete(:force => true)
    end
  end
end

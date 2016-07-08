require "serverspec"
require "docker"

set :backend, :docker

describe "Dockerfile" do
  before(:all) do
    image = Docker::Image.build_from_dir(
      'spec/rsc/ansible-project',
      {
        'dockerfile' => 'docker/Dockerfile'
      }
    )
    @container = Docker::Container.create(
      :Image => image.id,
      :Tty => true,
      :Cmd => 'bash'
    )
    @container.start
    set :docker_container, @container.id
  end

  describe file('/etc/ansible/roles/debops.secret') do
    it { should be_directory }
  end

  after(:all) do
    if !@container.nil?
      @container.delete(:force => true)
    end
  end
end

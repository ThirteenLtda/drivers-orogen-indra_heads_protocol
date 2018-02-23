require 'minitest/autorun'
require 'orocos/test/component'
require 'minitest/spec'

describe "indra_heads_protocol::Task" do
    include Orocos::Test::Component

    start 'task', 'indra_heads_protocol::Task' => 'task'
    before do
        task.io_port = "udpserver://4242"
        task.configure
        task.start
        @requested_configuration_r = task.requested_configuration.reader
        @response_w = task.response.writer
    end

    after do
        task.stop
        task.cleanup
    end

    def spawn_cmd(*args)
        Kernel.spawn(
            "indra_heads_protocol_cmd", "udp://localhost:4242", *args.map(&:to_s))
    end

    def assert_cmd_stops(pid)
        _pid, status = Process.waitpid2(pid)
        assert status.success?
    end

    def run_cmd(command_id, *args)
        before = Time.now
        pid = spawn_cmd(*args)
        conf = assert_has_one_new_sample @requested_configuration_r
        after = Time.now
        @response_w.write(
            Types.indra_heads_protocol.Response.new(
                command_id: command_id, status: :STATUS_OK)
        )
        assert_equal command_id, conf.command_id
        assert conf.time > before
        assert after > conf.time
        assert_cmd_stops pid
        conf
    end

    it "processes a STOP request" do
        conf = run_cmd :ID_DEPLOY, 'stop'
        assert_equal :STOP, conf.control_mode
    end

    it "processes a SELF_TEST request" do
        conf = run_cmd :ID_BITE, 'self-test'
        assert_equal :SELF_TEST, conf.control_mode
    end

    it "processes a pt rate request" do
        conf = run_cmd :ID_STATUS_REFRESH_RATE_PT, 'rate-pt', '20'
        assert_equal :RATE_20HZ, conf.rate_status_pt
    end

    it "processes a pt rate disabling request" do
        conf = run_cmd :ID_STATUS_REFRESH_RATE_PT, 'rate-pt', 'disable'
        assert_equal :RATE_DISABLED, conf.rate_status_pt
    end

    it "processes a IMU_RATE request" do
        conf = run_cmd :ID_STATUS_REFRESH_RATE_IMU, 'rate-imu', '10'
        assert_equal :RATE_10HZ, conf.rate_status_imu
    end

    it "processes a IMU_RATE disabling request" do
        conf = run_cmd :ID_STATUS_REFRESH_RATE_IMU, 'rate-imu', 'disable'
        assert_equal :RATE_DISABLED, conf.rate_status_imu
    end

    it "processes a TARGET request" do
        conf = run_cmd :ID_STABILIZATION_TARGET,
            'target', '0.01', '0.02', '0.3'

        assert_equal :STABILIZED, conf.control_mode
        assert_in_delta 0.01, conf.lat_lon_alt.latitude, 1e-6
        assert_in_delta 0.02, conf.lat_lon_alt.longitude, 1e-6
        assert_in_delta 0.3, conf.lat_lon_alt.altitude, 1e-6
    end

    it "keeps track of previous configuration changes in follow-up commands" do
        run_cmd :ID_STATUS_REFRESH_RATE_IMU,
            'rate-imu', '10'
        run_cmd :ID_STATUS_REFRESH_RATE_PT,
            'rate-pt', '20'
        conf = run_cmd :ID_STABILIZATION_TARGET,
            'target', '0.01', '0.02', '0.3'

        assert_in_delta 0.01, conf.lat_lon_alt.latitude, 1e-6
        assert_in_delta 0.02, conf.lat_lon_alt.longitude, 1e-6
        assert_in_delta 0.3, conf.lat_lon_alt.altitude, 1e-6
        assert_equal :STABILIZED, conf.control_mode
        assert_equal :RATE_10HZ, conf.rate_status_imu
        assert_equal :RATE_20HZ, conf.rate_status_pt
    end
end

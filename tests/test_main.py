from docker import Client
import docker.tls as tls
import time
from os import path
import os
import pprint
import subprocess
import json
import os.path
from sys import platform as _platform
import time
import requests
import filecmp

pp = pprint.PrettyPrinter(indent=4)

############################################
# Variables initialization
#############################################
# Image and container
IMAGE_NAME = 'fluent-plugin-juniper-telemetry'
CONTAINER_NAME = 'fluent-plugin-juniper-telemetry_test'
TCP_RELAY_CONTAINER_NAME = 'tcpreplay_test'

# Local ports that will be redirected to the Open NTI
# Startup will fail if some ports are already in use
TEST_PORT_JTI = 40000

# Local directories that will be mapped into the container
CURRENT_DIR = os.getcwd()

OUTPUT_FILE = CURRENT_DIR + "tests/output/fluentd_output.json"

DOCKER_IP = '127.0.0.1'
CONTAINER_ID = ''
TCP_REPLAY_CONTAINER_ID = ''
HANDLE_DB = ''

#############################################
class StreamLineBuildGenerator(object):
    def __init__(self, json_data):
        self.__dict__ = json.loads(json_data)

#############################################
# Container management
#############################################
def start_fluentd(conf_file, output_file):
    global c
    global CONTAINER_ID

    # Create new container
    TEST_CONFIG_DIR = '/root/fluentd-plugin-juniper-telemetry/tests/configs/'
    COMMAND="/usr/local/bin/fluentd -c " + TEST_CONFIG_DIR + conf_file + " --use-v1-config -p /root/fluentd-plugin-juniper-telemetry/lib/fluent/plugin"

    # Force Stop and delete existing container if exist
    try:
        old_container_id = c.inspect_container(CONTAINER_NAME)['Id']

        c.stop(container=old_container_id)
        c.remove_container(container=old_container_id)
    except:
        print "Container do not exit"

    container = c.create_container(
        image=IMAGE_NAME,
        command=COMMAND,
        name=CONTAINER_NAME,
        detach=True,
        environment=[
            "FLUENTD_OUTPUT_FILE=/root/fluentd-plugin-juniper-telemetry/tests/output/"+output_file,
        ],
        ports=[
            (40000, 'udp'),
        ],
        volumes=[
            '/root/fluentd-plugin-juniper-telemetry',
        ],
        host_config=c.create_host_config(
            port_bindings={
                '40000/udp': TEST_PORT_JTI,
            },
            binds=[
                CURRENT_DIR + ':/root/fluentd-plugin-juniper-telemetry',
            ]
        )
    )

    c.start(container)

    time.sleep(1)
    CONTAINER_ID = c.inspect_container(CONTAINER_NAME)['Id']
    return CONTAINER_ID

def stop_fluentd():
    global c

    # Force Stop and delete existing container if exist
    try:
        old_container_id = c.inspect_container(CONTAINER_NAME)['Id']

        c.stop(container=old_container_id)
        c.remove_container(container=old_container_id)
    except:
        print "Container do not exit"

def replay_file(file_name):
    global c

    try:
        old_container_id = c.inspect_container(TCP_RELAY_CONTAINER_NAME)['Id']
        c.stop(container=old_container_id)
        c.remove_container(container=old_container_id)
    except:
        print "Container do not exit"

    TEST_FIXTURE_DIR = CURRENT_DIR + '/tests/fixtures/'

    container = c.create_container(
        image='dgarros/tcpreplay',
        command='/usr/bin/tcpreplay --intf1=eth0 /data/' + file_name,
        name=TCP_RELAY_CONTAINER_NAME,
        volumes=[
            '/data'
        ],
        host_config=c.create_host_config(
            binds=[
                TEST_FIXTURE_DIR + ':/data',
            ]
        )
    )
    c.start(container)

def cleanup_test_output():

    import os, shutil
    folder = CURRENT_DIR + '/tests/output/'

    for the_file in os.listdir(folder):
        file_path = os.path.join(folder, the_file)
        try:
            if os.path.isfile(file_path):
                os.unlink(file_path)
            #elif os.path.isdir(file_path): shutil.rmtree(file_path)
        except Exception, e:
            print e

################################################################################
################################################################################

def test_connect_docker():
    global c
    global DOCKER_IP

    # initialize Docker Object
    if _platform == "linux" or _platform == "linux2":
        # linux
        c = Client(base_url='unix://var/run/docker.sock', version='1.20')
    elif _platform == "darwin":
        # MAC OS X
        dockerout = subprocess.check_output(
            ['/usr/local/bin/docker-machine ip default'],
            shell=True, stderr=subprocess.STDOUT
        )

        DOCKER_IP = dockerout.splitlines()[0]

        CERTS = path.join(
            path.expanduser('~'), '.docker', 'machine',
            'machines', 'default'
        )

        tls_config = tls.TLSConfig(
            client_cert=(
                path.join(CERTS, 'cert.pem'), path.join(CERTS, 'key.pem')
            ),
            ca_cert=path.join(CERTS, 'ca.pem'),
            assert_hostname=False,
            verify=True
        )

        url = "https://" + DOCKER_IP + ":2376"
        c = Client(base_url=url, tls=tls_config, version='1.20')

    elif _platform == "win32":
        exit

    # Check if connection to Docker work by listing all images
    list_images = c.images()
    assert len(list_images) >= 1

def test_output_module():

    CONFIG_FILE = 'fluent_structured.conf'
    OUTPUT_FILE = 'test_output_module.json'
    PCAP_FILE   = 'test_output_module/jti.pcap'

    start_fluentd(CONFIG_FILE, OUTPUT_FILE)

    replay_file(PCAP_FILE)

    time.sleep(1)

    assert os.path.isfile(CURRENT_DIR + '/tests/output/' + OUTPUT_FILE )

def test_jti_structured_ifd_01():

    CONFIG_FILE = 'fluent_structured.conf'
    OUTPUT_FILE = 'test_jti_structured_ifd_01.json'
    PCAP_FILE   = 'test_jti_structured_ifd_01/jti.pcap'

    start_fluentd(CONFIG_FILE, OUTPUT_FILE)
    replay_file(PCAP_FILE)

    time.sleep(1)

    test_results = filecmp.cmp(CURRENT_DIR + '/tests/fixtures/test_jti_structured_ifd_01/' + OUTPUT_FILE, CURRENT_DIR + '/tests/output/' + OUTPUT_FILE)

    if not test_results:
        with open(CURRENT_DIR + '/tests/output/' + OUTPUT_FILE, 'r') as fin:
            print fin.read()

    assert test_results

def teardown_module(module):
    global c

    # Delete all files in /tests/output/
    if not os.getenv('TRAVIS'):
        stop_fluentd()

        cleanup_test_output()

        try:
            old_container_id = c.inspect_container(TCP_RELAY_CONTAINER_NAME)['Id']
            c.stop(container=old_container_id)
            c.remove_container(container=old_container_id)
        except:
            print "Container do not exit"

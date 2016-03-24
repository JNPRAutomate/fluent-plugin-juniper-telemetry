

# Juniper Telemetry Interface (jvision)

## int-phy

Content inside sensor
```JSON
{
    "if_name"=>"ge-0/0/0",
    "init_time"=>1447183909,
    "snmp_if_index"=>517,
    "egress_queue_info"=>[
        {
            "queue_number"=>0,
            "packets"=>0,
            "bytes"=>0,
            "tail_drop_packets"=>0,
            "rl_drop_packets"=>0,
            "rl_drop_bytes"=>0,
            "red_drop_packets"=>0,
            "red_drop_bytes"=>0,
            "avg_buffer_occupancy"=>0,
            "cur_buffer_occupancy"=>0,
            "peak_buffer_occupancy"=>0,
            "allocated_buffer_size"=>0
        },
        {
            "queue_number"=>1,
            "packets"=>0,
            "bytes"=>0,
            "tail_drop_packets"=>0,
            "rl_drop_packets"=>0,
            "rl_drop_bytes"=>0,
            "red_drop_packets"=>0,
            "red_drop_bytes"=>0,
            "avg_buffer_occupancy"=>0,
            "cur_buffer_occupancy"=>0,
            "peak_buffer_occupancy"=>0,
            "allocated_buffer_size"=>0
        },
        {
            "queue_number"=>2,
            "packets"=>0,
            "bytes"=>0,
            "tail_drop_packets"=>0,
            "rl_drop_packets"=>0,
            "rl_drop_bytes"=>0,
            "red_drop_packets"=>0,
            "red_drop_bytes"=>0,
            "avg_buffer_occupancy"=>0,
            "cur_buffer_occupancy"=>0,
            "peak_buffer_occupancy"=>0,
            "allocated_buffer_size"=>0
        },
        {
            "queue_number"=>3,
            "packets"=>0,
            "bytes"=>0,
            "tail_drop_packets"=>0,
            "rl_drop_packets"=>0,
            "rl_drop_bytes"=>0,
            "red_drop_packets"=>0,
            "red_drop_bytes"=>0,
            "avg_buffer_occupancy"=>0,
            "cur_buffer_occupancy"=>0,
            "peak_buffer_occupancy"=>0,
            "allocated_buffer_size"=>0
        },
        {
            "queue_number"=>4,
            "packets"=>0,
            "bytes"=>0,
            "tail_drop_packets"=>0,
            "rl_drop_packets"=>0,
            "rl_drop_bytes"=>0,
            "red_drop_packets"=>0,
            "red_drop_bytes"=>0,
            "avg_buffer_occupancy"=>0,
            "cur_buffer_occupancy"=>0,
            "peak_buffer_occupancy"=>0,
            "allocated_buffer_size"=>0
        },
        {
            "queue_number"=>5,
            "packets"=>0,
            "bytes"=>0,
            "tail_drop_packets"=>0,
            "rl_drop_packets"=>0,
            "rl_drop_bytes"=>0,
            "red_drop_packets"=>0,
            "red_drop_bytes"=>0,
            "avg_buffer_occupancy"=>0,
            "cur_buffer_occupancy"=>0,
            "peak_buffer_occupancy"=>0,
            "allocated_buffer_size"=>0
        },
        {
            "queue_number"=>6,
            "packets"=>0,
            "bytes"=>0,
            "tail_drop_packets"=>0,
            "rl_drop_packets"=>0,
            "rl_drop_bytes"=>0,
            "red_drop_packets"=>0,
            "red_drop_bytes"=>0,
            "avg_buffer_occupancy"=>0,
            "cur_buffer_occupancy"=>0,
            "peak_buffer_occupancy"=>0,
            "allocated_buffer_size"=>0
        },
        {
            "queue_number"=>7,
            "packets"=>0,
            "bytes"=>0,
            "tail_drop_packets"=>0,
            "rl_drop_packets"=>0,
            "rl_drop_bytes"=>0,
            "red_drop_packets"=>0,
            "red_drop_bytes"=>0,
            "avg_buffer_occupancy"=>0,
            "cur_buffer_occupancy"=>0,
            "peak_buffer_occupancy"=>0,
            "allocated_buffer_size"=>0
        }
    ],
    "ingress_stats"=>{
        "if_pkts"=>12358765,
        "if_octets"=>1379549681,
        "if_1sec_pkts"=>10,
        "if_1sec_octets"=>1217,
        "if_uc_pkts"=>0,
        "if_mc_pkts"=>0,
        "if_bc_pkts"=>0
    },
    "egress_stats"=>{
        "if_pkts"=>800456,
        "if_octets"=>391825589,
        "if_1sec_pkts"=>0,
        "if_1sec_octets"=>127,
        "if_uc_pkts"=>0,
        "if_mc_pkts"=>0,
        "if_bc_pkts"=>0
    },
    "ingress_errors"=>{
        "if_in_errors"=>0,
        "if_in_qdrops"=>0,
        "if_in_frame_errors"=>0,
        "if_in_discards"=>0,
        "if_in_l3_incompletes"=>0,
        "if_in_l2chan_errors"=>0,
        "if_in_l2_mismatch_timeouts"=>0,
        "if_in_fifo_errors"=>0,
        "if_in_resource_errors"=>0
    }
}
```

# Analyticsd

### traffic-stats

```json
{
	"record-type": "traffic-stats",
	"time": 1448780496536409,
	"router-id": "s3bu-tme-qfx5100-6.englab.juniper.net",
	"port": "xe-0/0/10",
	"rxpkt": 45086456725,
	"rxucpkt": 45083448401,
	"rxmcpkt": 3008305,
	"rxbcpkt": 19,
	"rxpps": 0,
	"rxbyte": 13426309343040,
	"rxbps": 992,
	"rxdroppkt": 0,
	"rxcrcerr": 0,
	"txpkt": 18687319560,
	"txucpkt": 18673287866,
	"txmcpkt": 13141239,
	"txbcpkt": 890455,
	"txpps": 0,
	"txbyte": 5506859809812,
	"txbps": 0,
	"txdroppkt": 0,
	"txcrcerr": 0
}
```

### queue-stats

```json
{
	"record-type": "queue-stats",
	"time": 1449459248525100,
	"router-id": "WFD-QFX5100-48T-2",
	"port": "xe-0/0/0",
	"latency": 332,
	"queue-depth": 416
}
```

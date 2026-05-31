// Raspberry Pi 4 GENET Ethernet probe/status helpers for vibe-os.

.arch armv8-a

.equ PI4_FDT_BEGIN_NODE,                1
.equ PI4_FDT_END_NODE,                  2
.equ PI4_FDT_PROP,                      3
.equ PI4_FDT_NOP,                       4
.equ PI4_FDT_END,                       9
.equ VIBE_PI4_STATUS_PI4DTB_OK,         0x4454424f

.equ PI4_NET_GENET_BUS_BASE,            0x7d580000
.equ PI4_NET_GENET_ARM_BASE,            0xfd580000
.equ PI4_NET_GENET_SPAN,                0x00010000
.equ PI4_NET_GENET_PHY_ADDR,            1
.equ PI4_NET_GENET_MTU_FRAME,           1536
.equ PI4_NET_STATIC_IP0,                198
.equ PI4_NET_STATIC_IP1,                51
.equ PI4_NET_STATIC_IP2,                100
.equ PI4_NET_STATIC_IP3,                231
.equ PI4_NET_MAC0,                      0x02
.equ PI4_NET_MAC1,                      0x00
.equ PI4_NET_MAC2,                      0x00
.equ PI4_NET_MAC3,                      0x00
.equ PI4_NET_MAC4,                      0x00
.equ PI4_NET_MAC5,                      0x01
.equ PI4_NET_MAC0_BE32,                 0x02000000
.equ PI4_NET_MAC1_BE16,                 0x0001
.equ PI4_NET_HOST_IP0,                  198
.equ PI4_NET_HOST_IP1,                  51
.equ PI4_NET_HOST_IP2,                  100
.equ PI4_NET_HOST_IP3,                  23
.equ PI4_NET_HOST_MAC0,                 0x02
.equ PI4_NET_HOST_MAC1,                 0x00
.equ PI4_NET_HOST_MAC2,                 0x00
.equ PI4_NET_HOST_MAC3,                 0x00
.equ PI4_NET_HOST_MAC4,                 0x00
.equ PI4_NET_HOST_MAC5,                 0x02
.equ PI4_NET_LINK_WAIT_SECONDS,         2
.equ PI4_NET_POLL_SECONDS,              10
.equ PI4_NET_RX_RING_SIZE,              64
.equ PI4_NET_TX_RING_SIZE,              64
.equ PI4_NET_RX_RING_INDEX_MASK,        PI4_NET_RX_RING_SIZE - 1
.equ PI4_NET_TX_RING_INDEX_MASK,        PI4_NET_TX_RING_SIZE - 1
.equ PI4_NET_RX_BUF_BYTES,              2048
.equ PI4_NET_TX_BUF_BYTES,              2048
.equ PI4_NET_RX_FRAME_OFFSET,           66
.equ PI4_NET_TX_TSB_BYTES,              0
.equ PI4_NET_MIN_FRAME_BYTES,           60
.equ PI4_NET_MAX_FRAME_BYTES,           1514
.equ PI4_NET_CACHE_LINE_BYTES,          64

.equ PI4_GENET_SYS_REV_CTRL,            0x0000
.equ PI4_GENET_SYS_PORT_CTRL,           0x0004
.equ PI4_GENET_SYS_RBUF_FLUSH_CTRL,     0x0008
.equ PI4_GENET_SYS_TBUF_FLUSH_CTRL,     0x000c
.equ PI4_GENET_EXT_OFF,                 0x0080
.equ PI4_GENET_EXT_RGMII_OOB_CTRL,      0x000c
.equ PI4_GENET_RBUF_OFF,                0x0300
.equ PI4_GENET_RBUF_CTRL,               0x0000
.equ PI4_GENET_RBUF_CHK_CTRL,           0x0014
.equ PI4_GENET_RBUF_TBUF_SIZE_CTRL,     0x00b4
.equ PI4_GENET_TBUF_OFF,                0x0600
.equ PI4_GENET_TBUF_CTRL,               0x0000
.equ PI4_GENET_TBUF_BP_MC,              0x000c
.equ PI4_GENET_UMAC_OFF,                0x0800
.equ PI4_GENET_UMAC_CMD,                0x0008
.equ PI4_GENET_UMAC_MAC0,               0x000c
.equ PI4_GENET_UMAC_MAC1,               0x0010
.equ PI4_GENET_UMAC_MAX_FRAME_LEN,      0x0014
.equ PI4_GENET_UMAC_TX_IPG_LEN,         0x005c
.equ PI4_GENET_UMAC_MIB_CTRL,           0x0580
.equ PI4_GENET_UMAC_MDIO_CMD,           0x0614
.equ PI4_GENET_UMAC_TX_FLUSH,           0x0334
.equ PI4_GENET_UMAC_TX_FIFO_STATUS,     0x033c
.equ PI4_GENET_RDMA_OFF,                0x2000
.equ PI4_GENET_TDMA_OFF,                0x4000
.equ PI4_GENET_HFB_OFF,                 0x8000
.equ PI4_GENET_HFB_REG_OFF,             0xfc00
.equ PI4_GENET_HFB_CTRL,                0x0000
.equ PI4_GENET_HFB_FLT_ENABLE_LO,       0x0004
.equ PI4_GENET_HFB_FLT_ENABLE_HI,       0x0008
.equ PI4_GENET_HFB_FILTER0_LEN,         0x0048
.equ PI4_GENET_RBUF_HFB_EN,             1 << 0
.equ PI4_GENET_DMA_DESC_LENGTH_STATUS,  0x00
.equ PI4_GENET_DMA_DESC_ADDRESS_LO,     0x04
.equ PI4_GENET_DMA_DESC_ADDRESS_HI,     0x08
.equ PI4_GENET_DMA_DESC_BYTES,          12
.equ PI4_GENET_DMA_WORDS_PER_BD,        3
.equ PI4_GENET_DMA_DESC_TOTAL_BYTES,    0x0c00
.equ PI4_GENET_DMA_RING_BYTES,          0x40
.equ PI4_GENET_DMA_RINGS_BYTES,         0x440
.equ PI4_GENET_DMA_GLOBAL_BYTES,        PI4_GENET_DMA_DESC_TOTAL_BYTES + PI4_GENET_DMA_RINGS_BYTES
.equ PI4_GENET_DMA_RING_CFG,            0x00
.equ PI4_GENET_DMA_CTRL,                0x04
.equ PI4_GENET_DMA_STATUS,              0x08
.equ PI4_GENET_DMA_SCB_BURST_SIZE,      0x0c
.equ PI4_GENET_DMA_ARB_CTRL,            0x2c
.equ PI4_GENET_DMA_PRIORITY_0,          0x30
.equ PI4_GENET_DMA_INDEX2RING_0,        0x70
.equ PI4_GENET_RING_READ_PTR,           0x00
.equ PI4_GENET_RING_READ_PTR_HI,        0x04
.equ PI4_GENET_RING_CONS_INDEX,         0x08
.equ PI4_GENET_RING_PROD_INDEX,         0x0c
.equ PI4_GENET_RING_BUF_SIZE,           0x10
.equ PI4_GENET_RING_START_ADDR,         0x14
.equ PI4_GENET_RING_START_ADDR_HI,      0x18
.equ PI4_GENET_RING_END_ADDR,           0x1c
.equ PI4_GENET_RING_END_ADDR_HI,        0x20
.equ PI4_GENET_RING_MBUF_DONE_THRESH,   0x24
.equ PI4_GENET_RING_FLOW_PERIOD,        0x28
.equ PI4_GENET_RING_WRITE_PTR,          0x2c
.equ PI4_GENET_RING_WRITE_PTR_HI,       0x30
.equ PI4_GENET_RDMA_WRITE_PTR,          PI4_GENET_RING_READ_PTR
.equ PI4_GENET_RDMA_WRITE_PTR_HI,       PI4_GENET_RING_READ_PTR_HI
.equ PI4_GENET_RDMA_PROD_INDEX,         PI4_GENET_RING_CONS_INDEX
.equ PI4_GENET_RDMA_CONS_INDEX,         PI4_GENET_RING_PROD_INDEX
.equ PI4_GENET_RDMA_READ_PTR,           PI4_GENET_RING_WRITE_PTR
.equ PI4_GENET_RDMA_READ_PTR_HI,        PI4_GENET_RING_WRITE_PTR_HI

.equ PI4_GENET_PORT_MODE_EXT_GPHY,      3
.equ PI4_GENET_RGMII_LINK,              1 << 4
.equ PI4_GENET_RGMII_OOB_DISABLE,       1 << 5
.equ PI4_GENET_RGMII_MODE_EN,           1 << 6
.equ PI4_GENET_CMD_TX_EN,               1 << 0
.equ PI4_GENET_CMD_RX_EN,               1 << 1
.equ PI4_GENET_CMD_SPEED_1000,          2 << 2
.equ PI4_GENET_CMD_PROMISC,             1 << 4
.equ PI4_GENET_CMD_PAD_EN,              1 << 5
.equ PI4_GENET_CMD_SW_RESET,            1 << 13
.equ PI4_GENET_CMD_RX_PAUSE_IGNORE,     1 << 8
.equ PI4_GENET_CMD_TX_PAUSE_IGNORE,     1 << 28
.equ PI4_GENET_CMD_TX_RX_EN,            1 << 29
.equ PI4_GENET_RBUF_64B_EN,             1 << 0
.equ PI4_GENET_RBUF_ALIGN_2B,           1 << 1
.equ PI4_GENET_RBUF_RXCHK_EN,           1 << 0
.equ PI4_GENET_RBUF_L3_PARSE_DIS,       1 << 5
.equ PI4_GENET_TBUF_64B_EN,             1 << 0
.equ PI4_GENET_TBUF_BP_MC_VALUE,        0x0000ffff
.equ PI4_GENET_UMAC_TX_IPG_96BIT,       0x00003c00
.equ PI4_GENET_MIB_RESET_RX,            1 << 0
.equ PI4_GENET_MIB_RESET_RUNT,          1 << 1
.equ PI4_GENET_MIB_RESET_TX,            1 << 2
.equ PI4_GENET_DMA_EN,                  1 << 0
.equ PI4_GENET_DMA_RING0_EN,            1 << 1
.equ PI4_GENET_DMA_DISABLED,            1 << 0
.equ PI4_GENET_DMA_BURST_BCM2711,       0x08
.equ PI4_GENET_DMA_ARBITER_SP,          0x02
.equ PI4_GENET_DMA_RING_ENABLE_VALUE,   PI4_GENET_DMA_EN | PI4_GENET_DMA_RING0_EN
.equ PI4_GENET_DMA_RX_RING_END_WORD,    (PI4_NET_RX_RING_SIZE * PI4_GENET_DMA_WORDS_PER_BD) - 1
.equ PI4_GENET_DMA_TX_RING_END_WORD,    (PI4_NET_TX_RING_SIZE * PI4_GENET_DMA_WORDS_PER_BD) - 1
.equ PI4_GENET_DMA_RX_RING_BUF_SIZE_VALUE, (PI4_NET_RX_RING_SIZE << 16) | PI4_NET_RX_BUF_BYTES
.equ PI4_GENET_DMA_TX_RING_BUF_SIZE_VALUE, (PI4_NET_TX_RING_SIZE << 16) | PI4_NET_RX_BUF_BYTES
.equ PI4_GENET_DMA_RX_XON_XOFF_VALUE,   (5 << 16) | 16
.equ PI4_GENET_DMA_TX_DONE_THRESH,      1
.equ PI4_GENET_DMA_TX_APPEND_CRC,       0x0040
.equ PI4_GENET_DMA_TX_QTAG_VALUE,       0x1f80
.equ PI4_GENET_DMA_SOP,                 0x2000
.equ PI4_GENET_DMA_EOP,                 0x4000
.equ PI4_GENET_DMA_BUFLENGTH_SHIFT,     16
.equ PI4_GENET_UMAC_MIB_RX_PKTS,        0x0428
.equ PI4_GENET_UMAC_MIB_RX_BCAST,       0x0434
.equ PI4_GENET_UMAC_MIB_RX_GOOD,        0x0464
.equ PI4_GENET_UMAC_MIB_TX_64,          0x0480
.equ PI4_GENET_UMAC_MIB_TX_PKTS,        0x04a8
.equ PI4_GENET_UMAC_MIB_TX_BCAST,       0x04b0
.equ PI4_GENET_UMAC_MIB_TX_BYTES,       0x04e8
.equ PI4_GENET_UMAC_MIB_TX_GOOD,        0x04ec

.equ PI4_NET_ETH_TYPE_ARP,              0x0806
.equ PI4_NET_ETH_TYPE_IPV4,             0x0800
.equ PI4_NET_ARP_HTYPE_ETH,             0x0001
.equ PI4_NET_ARP_OP_REQUEST,            0x0001
.equ PI4_NET_ARP_OP_REPLY,              0x0002
.equ PI4_NET_IPV4_PROTO_ICMP,           1
.equ PI4_NET_IPV4_PROTO_TCP,            6
.equ PI4_NET_IPV4_PROTO_UDP,            17
.equ PI4_NET_ICMP_ECHO_REQUEST,         8
.equ PI4_NET_ICMP_ECHO_REPLY,           0
.equ PI4_NET_TCP_LISTEN_PORT,           2222
.equ PI4_NET_TCP_SERVER_SEQ,            0x56494245
.equ PI4_NET_SSH_BANNER_LEN,            21
.equ PI4_NET_SSH_KEXINIT_PACKET_LEN,    160
.equ PI4_NET_SSH_MSG_KEXINIT,           20
.equ PI4_NET_UDP_PROBE_PORT,            23230
.equ PI4_NET_UDP_PROBE_LEN,             22
.equ PI4_NET_UDP_IP_LEN,                20 + 8 + PI4_NET_UDP_PROBE_LEN
.equ PI4_NET_UDP_FRAME_LEN,             14 + PI4_NET_UDP_IP_LEN
.equ PI4_NET_TCP_FLAG_FIN,              0x01
.equ PI4_NET_TCP_FLAG_SYN,              0x02
.equ PI4_NET_TCP_FLAG_PSH,              0x08
.equ PI4_NET_TCP_FLAG_ACK,              0x10

.equ PI4_GENET_MDIO_START_BUSY,         1 << 29
.equ PI4_GENET_MDIO_READ_FAIL,          1 << 28
.equ PI4_GENET_MDIO_RD,                 2 << 26
.equ PI4_GENET_MDIO_WR,                 1 << 26
.equ PI4_GENET_MDIO_PMD_SHIFT,          21
.equ PI4_GENET_MDIO_REG_SHIFT,          16
.equ PI4_GENET_MDIO_POLL_LIMIT,         0x10000

.equ PI4_PHY_REG_BMSR,                  1
.equ PI4_PHY_REG_ID1,                   2
.equ PI4_PHY_REG_ID2,                   3
.equ PI4_PHY_REG_AUX_CTL,               24
.equ PI4_PHY_REG_SHADOW,                28
.equ PI4_PHY_BMSR_LINK_STATUS,          1 << 2
.equ PI4_BCM54XX_AUXCTL_MISC_READ,      0x7007
.equ PI4_BCM54XX_AUXCTL_MISC_WREN,      0x8000
.equ PI4_BCM54XX_AUXCTL_MISC_RGMII_EN,  0x0080
.equ PI4_BCM54XX_AUXCTL_MISC_RGMII_SKEW_EN, 0x0100
.equ PI4_BCM54XX_SHD_WRITE,             0x8000
.equ PI4_BCM54XX_SHD_DATA_MASK,         0x03ff
.equ PI4_BCM54810_SHD_CLK_CTL,          3
.equ PI4_BCM54810_SHD_CLK_CTL_SELECT,   PI4_BCM54810_SHD_CLK_CTL << 10
.equ PI4_BCM54810_SHD_CLK_CTL_GTXCLK_EN, 1 << 9

.equ PI4_NET_PROBE_WAIT,                0
.equ PI4_NET_PROBE_DT_OK,               1
.equ PI4_NET_PROBE_MMIO_OK,             2
.equ PI4_NET_PROBE_MDIO_OK,             3
.equ PI4_NET_PROBE_LINK_UP,             4
.equ PI4_NET_PROBE_LINK_DOWN,           5
.equ PI4_NET_PROBE_BAD,                 0xff

.section .text.pi4_net, "ax", %progbits
.balign 16

.global pi4_net_reset_status
.type pi4_net_reset_status, %function
pi4_net_reset_status:
    adr x0, pi4_net_status_values_start
    adr x1, pi4_net_status_values_end
.Lpi4_net_reset_next:
    cmp x0, x1
    b.hs .Lpi4_net_reset_done
    str xzr, [x0], #8
    b .Lpi4_net_reset_next
.Lpi4_net_reset_done:
    ret
.size pi4_net_reset_status, . - pi4_net_reset_status

.global pi4_net_probe_genet_status
.type pi4_net_probe_genet_status, %function
pi4_net_probe_genet_status:
    stp x29, x30, [sp, #-32]!
    mov x29, sp
    stp x19, x20, [sp, #16]

    bl pi4_net_scan_genet_dtb
    cbz x0, .Lpi4_net_probe_done

    adr x1, pi4_net_status_probe
    mov x0, #PI4_NET_PROBE_DT_OK
    str x0, [x1]
    ldr x19, =PI4_NET_GENET_ARM_BASE
    adr x1, pi4_net_status_bus_base
    ldr x0, =PI4_NET_GENET_BUS_BASE
    str x0, [x1]
    adr x1, pi4_net_status_arm_base
    str x19, [x1]
    adr x1, pi4_net_status_span
    mov x0, #PI4_NET_GENET_SPAN
    str x0, [x1]

    ldr w0, [x19, #PI4_GENET_SYS_REV_CTRL]
    adr x1, pi4_net_status_sys_rev
    str x0, [x1]

    mov w0, #PI4_GENET_PORT_MODE_EXT_GPHY
    str w0, [x19, #PI4_GENET_SYS_PORT_CTRL]
    ldr w0, [x19, #PI4_GENET_SYS_PORT_CTRL]
    adr x1, pi4_net_status_port_ctrl
    str x0, [x1]

    ldr w0, [x19, #(PI4_GENET_EXT_OFF + PI4_GENET_EXT_RGMII_OOB_CTRL)]
    bic w0, w0, #PI4_GENET_RGMII_OOB_DISABLE
    orr w0, w0, #PI4_GENET_RGMII_MODE_EN
    str w0, [x19, #(PI4_GENET_EXT_OFF + PI4_GENET_EXT_RGMII_OOB_CTRL)]
    ldr w0, [x19, #(PI4_GENET_EXT_OFF + PI4_GENET_EXT_RGMII_OOB_CTRL)]
    adr x1, pi4_net_status_rgmii_oob
    str x0, [x1]

    ldr w0, [x19, #(PI4_GENET_UMAC_OFF + PI4_GENET_UMAC_CMD)]
    adr x1, pi4_net_status_umac_cmd_before
    str x0, [x1]
    bic w0, w0, #PI4_GENET_CMD_SW_RESET
    bic w0, w0, #(3 << 2)
    orr w0, w0, #PI4_GENET_CMD_SPEED_1000
    adr x1, pi4_net_status_umac_cmd_write
    str x0, [x1]
    str w0, [x19, #(PI4_GENET_UMAC_OFF + PI4_GENET_UMAC_CMD)]
    ldr w0, [x19, #(PI4_GENET_UMAC_OFF + PI4_GENET_UMAC_CMD)]
    adr x1, pi4_net_status_umac_cmd_after
    str x0, [x1]
    adr x1, pi4_net_status_umac_cmd
    str x0, [x1]

    mov w0, #PI4_NET_GENET_MTU_FRAME
    str w0, [x19, #(PI4_GENET_UMAC_OFF + PI4_GENET_UMAC_MAX_FRAME_LEN)]

    ldr w0, [x19, #(PI4_GENET_RBUF_OFF + PI4_GENET_RBUF_CTRL)]
    mov w7, #(PI4_GENET_RBUF_64B_EN | PI4_GENET_RBUF_ALIGN_2B)
    orr w0, w0, w7
    str w0, [x19, #(PI4_GENET_RBUF_OFF + PI4_GENET_RBUF_CTRL)]
    ldr w0, [x19, #(PI4_GENET_RBUF_OFF + PI4_GENET_RBUF_CTRL)]
    adr x1, pi4_net_status_rbuf_ctrl
    str x0, [x1]

    ldr w0, [x19, #(PI4_GENET_RBUF_OFF + PI4_GENET_RBUF_CHK_CTRL)]
    mov w7, #(PI4_GENET_RBUF_RXCHK_EN | PI4_GENET_RBUF_L3_PARSE_DIS)
    orr w0, w0, w7
    str w0, [x19, #(PI4_GENET_RBUF_OFF + PI4_GENET_RBUF_CHK_CTRL)]
    ldr w0, [x19, #(PI4_GENET_RBUF_OFF + PI4_GENET_RBUF_CHK_CTRL)]
    adr x1, pi4_net_status_rbuf_chk
    str x0, [x1]

    adr x1, pi4_net_status_probe
    mov x0, #PI4_NET_PROBE_MMIO_OK
    str x0, [x1]

    mov w0, #PI4_NET_GENET_PHY_ADDR
    mov w1, #PI4_PHY_REG_ID1
    bl pi4_net_mdio_read
    cbnz x0, .Lpi4_net_probe_mdio_bad
    adr x2, pi4_net_status_phy_id1
    str x1, [x2]

    mov w0, #PI4_NET_GENET_PHY_ADDR
    mov w1, #PI4_PHY_REG_ID2
    bl pi4_net_mdio_read
    cbnz x0, .Lpi4_net_probe_mdio_bad
    adr x2, pi4_net_status_phy_id2
    str x1, [x2]

    bl pi4_net_configure_bcm54213pe_rgmii_rxid

    mrs x20, CNTFRQ_EL0
    mov x0, #PI4_NET_LINK_WAIT_SECONDS
    mul x20, x20, x0
    mrs x0, CNTPCT_EL0
    add x20, x20, x0

.Lpi4_net_probe_link_wait:
    mov w0, #PI4_NET_GENET_PHY_ADDR
    mov w1, #PI4_PHY_REG_BMSR
    bl pi4_net_mdio_read
    cbnz x0, .Lpi4_net_probe_mdio_bad
    mov w0, #PI4_NET_GENET_PHY_ADDR
    mov w1, #PI4_PHY_REG_BMSR
    bl pi4_net_mdio_read
    cbnz x0, .Lpi4_net_probe_mdio_bad

    adr x2, pi4_net_status_phy_bmsr
    str x1, [x2]
    tst x1, #PI4_PHY_BMSR_LINK_STATUS
    b.ne .Lpi4_net_probe_link_ready
    mrs x0, CNTPCT_EL0
    cmp x0, x20
    b.lo .Lpi4_net_probe_link_wait

.Lpi4_net_probe_link_ready:
    adr x2, pi4_net_status_probe
    mov x0, #PI4_NET_PROBE_MDIO_OK
    str x0, [x2]
    tst x1, #PI4_PHY_BMSR_LINK_STATUS
    b.eq .Lpi4_net_probe_link_down

    ldr w0, [x19, #(PI4_GENET_EXT_OFF + PI4_GENET_EXT_RGMII_OOB_CTRL)]
    orr w0, w0, #PI4_GENET_RGMII_LINK
    str w0, [x19, #(PI4_GENET_EXT_OFF + PI4_GENET_EXT_RGMII_OOB_CTRL)]
    ldr w0, [x19, #(PI4_GENET_EXT_OFF + PI4_GENET_EXT_RGMII_OOB_CTRL)]
    adr x1, pi4_net_status_rgmii_oob
    str x0, [x1]
    adr x1, pi4_net_status_link
    mov x0, #1
    str x0, [x1]
    adr x1, pi4_net_status_probe
    mov x0, #PI4_NET_PROBE_LINK_UP
    str x0, [x1]
    b .Lpi4_net_probe_done

.Lpi4_net_probe_link_down:
    adr x1, pi4_net_status_link
    str xzr, [x1]
    adr x1, pi4_net_status_probe
    mov x0, #PI4_NET_PROBE_LINK_DOWN
    str x0, [x1]
    b .Lpi4_net_probe_done

.Lpi4_net_probe_mdio_bad:
    adr x1, pi4_net_status_result
    str x0, [x1]
    adr x1, pi4_net_status_probe
    mov x0, #PI4_NET_PROBE_BAD
    str x0, [x1]

.Lpi4_net_probe_done:
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret
.size pi4_net_probe_genet_status, . - pi4_net_probe_genet_status

.type pi4_net_mdio_read, %function
pi4_net_mdio_read:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    ldr x2, =PI4_NET_GENET_ARM_BASE + PI4_GENET_UMAC_OFF + PI4_GENET_UMAC_MDIO_CMD
    and w0, w0, #0x1f
    and w1, w1, #0x1f
    adr x3, pi4_net_status_phy_addr
    uxtw x4, w0
    str x4, [x3]

    mov w5, #PI4_GENET_MDIO_POLL_LIMIT
.Lpi4_net_mdio_wait_idle:
    ldr w6, [x2]
    tst w6, #PI4_GENET_MDIO_START_BUSY
    b.eq .Lpi4_net_mdio_idle
    subs w5, w5, #1
    b.ne .Lpi4_net_mdio_wait_idle
    mov x0, #5
    b .Lpi4_net_mdio_done

.Lpi4_net_mdio_idle:
    ldr w6, =PI4_GENET_MDIO_START_BUSY | PI4_GENET_MDIO_RD
    orr w6, w6, w0, lsl #PI4_GENET_MDIO_PMD_SHIFT
    orr w6, w6, w1, lsl #PI4_GENET_MDIO_REG_SHIFT
    str w6, [x2]
    adr x3, pi4_net_status_mdio_cmd
    uxtw x4, w6
    str x4, [x3]

    mov w5, #PI4_GENET_MDIO_POLL_LIMIT
.Lpi4_net_mdio_wait_done:
    ldr w6, [x2]
    tst w6, #PI4_GENET_MDIO_START_BUSY
    b.eq .Lpi4_net_mdio_read_done
    subs w5, w5, #1
    b.ne .Lpi4_net_mdio_wait_done
    mov x0, #5
    b .Lpi4_net_mdio_done

.Lpi4_net_mdio_read_done:
    adr x3, pi4_net_status_mdio_cmd
    uxtw x4, w6
    str x4, [x3]
    tst w6, #PI4_GENET_MDIO_READ_FAIL
    b.eq .Lpi4_net_mdio_ok
    mov x0, #5
    b .Lpi4_net_mdio_done

.Lpi4_net_mdio_ok:
    and x1, x6, #0xffff
    mov x0, xzr

.Lpi4_net_mdio_done:
    ldp x29, x30, [sp], #16
    ret
.size pi4_net_mdio_read, . - pi4_net_mdio_read

.type pi4_net_mdio_write, %function
pi4_net_mdio_write:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    ldr x3, =PI4_NET_GENET_ARM_BASE + PI4_GENET_UMAC_OFF + PI4_GENET_UMAC_MDIO_CMD

    mov w5, #PI4_GENET_MDIO_POLL_LIMIT
.Lpi4_net_mdio_write_wait_idle:
    ldr w6, [x3]
    tst w6, #PI4_GENET_MDIO_START_BUSY
    b.eq .Lpi4_net_mdio_write_idle
    subs w5, w5, #1
    b.ne .Lpi4_net_mdio_write_wait_idle
    mov x0, #1
    b .Lpi4_net_mdio_write_done

.Lpi4_net_mdio_write_idle:
    ldr w6, =PI4_GENET_MDIO_START_BUSY | PI4_GENET_MDIO_WR
    orr w6, w6, w0, lsl #PI4_GENET_MDIO_PMD_SHIFT
    orr w6, w6, w1, lsl #PI4_GENET_MDIO_REG_SHIFT
    uxth w2, w2
    orr w6, w6, w2
    str w6, [x3]
    adr x4, pi4_net_status_mdio_cmd
    str x6, [x4]

    mov w5, #PI4_GENET_MDIO_POLL_LIMIT
.Lpi4_net_mdio_write_wait_done:
    ldr w6, [x3]
    tst w6, #PI4_GENET_MDIO_START_BUSY
    b.eq .Lpi4_net_mdio_write_ok
    subs w5, w5, #1
    b.ne .Lpi4_net_mdio_write_wait_done
    mov x0, #1
    b .Lpi4_net_mdio_write_done

.Lpi4_net_mdio_write_ok:
    mov x0, xzr

.Lpi4_net_mdio_write_done:
    ldp x29, x30, [sp], #16
    ret
.size pi4_net_mdio_write, . - pi4_net_mdio_write

.type pi4_net_configure_bcm54213pe_rgmii_rxid, %function
pi4_net_configure_bcm54213pe_rgmii_rxid:
    stp x29, x30, [sp, #-32]!
    mov x29, sp
    str x19, [sp, #16]

    mov w0, #PI4_NET_GENET_PHY_ADDR
    mov w1, #PI4_PHY_REG_AUX_CTL
    ldr w2, =PI4_BCM54XX_AUXCTL_MISC_READ
    bl pi4_net_mdio_write
    cbnz x0, .Lpi4_net_phy_cfg_done

    mov w0, #PI4_NET_GENET_PHY_ADDR
    mov w1, #PI4_PHY_REG_AUX_CTL
    bl pi4_net_mdio_read
    cbnz x0, .Lpi4_net_phy_cfg_done
    mov w2, w1
    ldr w3, =(PI4_BCM54XX_AUXCTL_MISC_WREN | PI4_BCM54XX_AUXCTL_MISC_RGMII_EN | PI4_BCM54XX_AUXCTL_MISC_RGMII_SKEW_EN)
    orr w2, w2, w3
    mov w0, #PI4_NET_GENET_PHY_ADDR
    mov w1, #PI4_PHY_REG_AUX_CTL
    bl pi4_net_mdio_write
    cbnz x0, .Lpi4_net_phy_cfg_done

    mov w0, #PI4_NET_GENET_PHY_ADDR
    mov w1, #PI4_PHY_REG_SHADOW
    mov w2, #PI4_BCM54810_SHD_CLK_CTL_SELECT
    bl pi4_net_mdio_write
    cbnz x0, .Lpi4_net_phy_cfg_done

    mov w0, #PI4_NET_GENET_PHY_ADDR
    mov w1, #PI4_PHY_REG_SHADOW
    bl pi4_net_mdio_read
    cbnz x0, .Lpi4_net_phy_cfg_done
    mov w2, w1
    and w2, w2, #PI4_BCM54XX_SHD_DATA_MASK
    bic w2, w2, #PI4_BCM54810_SHD_CLK_CTL_GTXCLK_EN
    ldr w3, =(PI4_BCM54XX_SHD_WRITE | PI4_BCM54810_SHD_CLK_CTL_SELECT)
    orr w2, w2, w3
    mov w0, #PI4_NET_GENET_PHY_ADDR
    mov w1, #PI4_PHY_REG_SHADOW
    bl pi4_net_mdio_write

.Lpi4_net_phy_cfg_done:
    ldr x19, [sp, #16]
    ldp x29, x30, [sp], #32
    ret
.size pi4_net_configure_bcm54213pe_rgmii_rxid, . - pi4_net_configure_bcm54213pe_rgmii_rxid

.global pi4_net_run_static_ipv4_probe
.type pi4_net_run_static_ipv4_probe, %function
pi4_net_run_static_ipv4_probe:
    stp x29, x30, [sp, #-64]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    str x23, [sp, #48]

    adr x0, pi4_net_status_probe
    ldr x0, [x0]
    cmp x0, #PI4_NET_PROBE_LINK_UP
    b.ne .Lpi4_net_ipv4_probe_done

    bl pi4_net_init_dma_static_ipv4
    cbnz x0, .Lpi4_net_ipv4_probe_done

    mrs x21, CNTFRQ_EL0
    mov x19, x21
    mov x20, #PI4_NET_POLL_SECONDS
    mul x19, x19, x20
    mrs x20, CNTPCT_EL0
    add x20, x20, x19
    mrs x22, CNTPCT_EL0
    adr x0, pi4_net_status_poll_deadline
    str x20, [x0]

.Lpi4_net_ipv4_probe_loop:
    mrs x23, CNTPCT_EL0
    cmp x23, x22
    b.lo .Lpi4_net_ipv4_probe_poll
    bl pi4_net_send_gratuitous_arp
    bl pi4_net_send_udp_probe
    add x22, x22, x21
.Lpi4_net_ipv4_probe_poll:
    bl pi4_net_poll_one_packet
    mrs x0, CNTPCT_EL0
    cmp x0, x20
    b.lo .Lpi4_net_ipv4_probe_loop

.Lpi4_net_ipv4_probe_done:
    ldr x23, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret
.size pi4_net_run_static_ipv4_probe, . - pi4_net_run_static_ipv4_probe

.type pi4_net_init_dma_static_ipv4, %function
pi4_net_init_dma_static_ipv4:
    stp x29, x30, [sp, #-80]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    str x25, [sp, #64]

    ldr x0, =pi4_net_rx_buffers
    mov x1, #(PI4_NET_RX_RING_SIZE * PI4_NET_RX_BUF_BYTES)
    bl pi4_net_zero_region
    ldr x0, =pi4_net_tx_buffers
    mov x1, #(PI4_NET_TX_RING_SIZE * PI4_NET_TX_BUF_BYTES)
    bl pi4_net_zero_region
    ldr x0, =pi4_net_rx_buffers
    mov x1, #(PI4_NET_RX_RING_SIZE * PI4_NET_RX_BUF_BYTES)
    bl pi4_net_clean_invalidate_dcache_range
    ldr x0, =pi4_net_tx_buffers
    mov x1, #(PI4_NET_TX_RING_SIZE * PI4_NET_TX_BUF_BYTES)
    bl pi4_net_clean_invalidate_dcache_range

    ldr x19, =PI4_NET_GENET_ARM_BASE
    add x20, x19, #PI4_GENET_RDMA_OFF
    add x21, x19, #PI4_GENET_TDMA_OFF

    add x22, x20, #PI4_GENET_DMA_DESC_TOTAL_BYTES
    add x22, x22, #PI4_GENET_DMA_RINGS_BYTES
    str wzr, [x22, #PI4_GENET_DMA_CTRL]
    str wzr, [x22, #PI4_GENET_DMA_RING_CFG]
    add x22, x21, #PI4_GENET_DMA_DESC_TOTAL_BYTES
    add x22, x22, #PI4_GENET_DMA_RINGS_BYTES
    str wzr, [x22, #PI4_GENET_DMA_CTRL]
    str wzr, [x22, #PI4_GENET_DMA_RING_CFG]
    dsb sy

    mov w0, #1
    str w0, [x19, #(PI4_GENET_UMAC_OFF + PI4_GENET_UMAC_TX_FLUSH)]
    str wzr, [x19, #(PI4_GENET_UMAC_OFF + PI4_GENET_UMAC_TX_FLUSH)]
    ldr w0, =(PI4_GENET_MIB_RESET_RX | PI4_GENET_MIB_RESET_TX | PI4_GENET_MIB_RESET_RUNT)
    str w0, [x19, #(PI4_GENET_UMAC_OFF + PI4_GENET_UMAC_MIB_CTRL)]
    str wzr, [x19, #(PI4_GENET_UMAC_OFF + PI4_GENET_UMAC_MIB_CTRL)]

    str wzr, [x19, #PI4_GENET_SYS_RBUF_FLUSH_CTRL]
    dsb sy
    ldr w0, [x19, #PI4_GENET_SYS_RBUF_FLUSH_CTRL]
    adr x1, pi4_net_status_sys_rbuf_flush
    str x0, [x1]
    mov w0, #PI4_GENET_CMD_SW_RESET
    str w0, [x19, #(PI4_GENET_UMAC_OFF + PI4_GENET_UMAC_CMD)]
    dsb sy
    ldr w0, [x19, #(PI4_GENET_UMAC_OFF + PI4_GENET_UMAC_CMD)]
    adr x1, pi4_net_status_umac_cmd_reset
    str x0, [x1]

    ldr w0, [x19, #(PI4_GENET_TBUF_OFF + PI4_GENET_TBUF_CTRL)]
    bic w0, w0, #PI4_GENET_TBUF_64B_EN
    str w0, [x19, #(PI4_GENET_TBUF_OFF + PI4_GENET_TBUF_CTRL)]
    ldr w0, =PI4_GENET_TBUF_BP_MC_VALUE
    str w0, [x19, #(PI4_GENET_TBUF_OFF + PI4_GENET_TBUF_BP_MC)]

    mov w0, #1
    str w0, [x19, #(PI4_GENET_RBUF_OFF + PI4_GENET_RBUF_TBUF_SIZE_CTRL)]
    ldr w0, =PI4_NET_MAC0_BE32
    str w0, [x19, #(PI4_GENET_UMAC_OFF + PI4_GENET_UMAC_MAC0)]
    mov w0, #PI4_NET_MAC1_BE16
    str w0, [x19, #(PI4_GENET_UMAC_OFF + PI4_GENET_UMAC_MAC1)]
    mov w0, #PI4_NET_GENET_MTU_FRAME
    str w0, [x19, #(PI4_GENET_UMAC_OFF + PI4_GENET_UMAC_MAX_FRAME_LEN)]
    ldr w0, =PI4_GENET_UMAC_TX_IPG_96BIT
    str w0, [x19, #(PI4_GENET_UMAC_OFF + PI4_GENET_UMAC_TX_IPG_LEN)]

    bl pi4_net_init_hfb_default_ring0

    ldr x23, =pi4_net_rx_buffers
    mov x24, xzr
.Lpi4_net_init_rx_desc_loop:
    cmp x24, #PI4_NET_RX_RING_SIZE
    b.hs .Lpi4_net_init_rx_desc_done
    mov x0, #PI4_GENET_DMA_DESC_BYTES
    mul x1, x24, x0
    add x2, x20, x1
    add x3, x23, x24, lsl #11
    str wzr, [x2, #PI4_GENET_DMA_DESC_LENGTH_STATUS]
    str w3, [x2, #PI4_GENET_DMA_DESC_ADDRESS_LO]
    str wzr, [x2, #PI4_GENET_DMA_DESC_ADDRESS_HI]
    add x24, x24, #1
    b .Lpi4_net_init_rx_desc_loop
.Lpi4_net_init_rx_desc_done:

    mov x24, xzr
.Lpi4_net_init_tx_desc_loop:
    cmp x24, #PI4_NET_TX_RING_SIZE
    b.hs .Lpi4_net_init_tx_desc_done
    mov x0, #PI4_GENET_DMA_DESC_BYTES
    mul x1, x24, x0
    add x2, x21, x1
    str wzr, [x2, #PI4_GENET_DMA_DESC_LENGTH_STATUS]
    str wzr, [x2, #PI4_GENET_DMA_DESC_ADDRESS_LO]
    str wzr, [x2, #PI4_GENET_DMA_DESC_ADDRESS_HI]
    add x24, x24, #1
    b .Lpi4_net_init_tx_desc_loop
.Lpi4_net_init_tx_desc_done:

    add x22, x20, #PI4_GENET_DMA_DESC_TOTAL_BYTES
    str wzr, [x22, #PI4_GENET_RDMA_PROD_INDEX]
    str wzr, [x22, #PI4_GENET_RDMA_CONS_INDEX]
    ldr w0, =PI4_GENET_DMA_RX_RING_BUF_SIZE_VALUE
    str w0, [x22, #PI4_GENET_RING_BUF_SIZE]
    ldr w0, =PI4_GENET_DMA_RX_XON_XOFF_VALUE
    str w0, [x22, #PI4_GENET_RING_FLOW_PERIOD]
    str wzr, [x22, #PI4_GENET_RING_START_ADDR]
    str wzr, [x22, #PI4_GENET_RING_START_ADDR_HI]
    str wzr, [x22, #PI4_GENET_RDMA_READ_PTR]
    str wzr, [x22, #PI4_GENET_RDMA_READ_PTR_HI]
    str wzr, [x22, #PI4_GENET_RDMA_WRITE_PTR]
    str wzr, [x22, #PI4_GENET_RDMA_WRITE_PTR_HI]
    ldr w0, =PI4_GENET_DMA_RX_RING_END_WORD
    str w0, [x22, #PI4_GENET_RING_END_ADDR]
    str wzr, [x22, #PI4_GENET_RING_END_ADDR_HI]

    add x22, x21, #PI4_GENET_DMA_DESC_TOTAL_BYTES
    str wzr, [x22, #PI4_GENET_RING_PROD_INDEX]
    str wzr, [x22, #PI4_GENET_RING_CONS_INDEX]
    ldr w0, =PI4_GENET_DMA_TX_RING_BUF_SIZE_VALUE
    str w0, [x22, #PI4_GENET_RING_BUF_SIZE]
    mov w0, #PI4_GENET_DMA_TX_DONE_THRESH
    str w0, [x22, #PI4_GENET_RING_MBUF_DONE_THRESH]
    str wzr, [x22, #PI4_GENET_RING_FLOW_PERIOD]
    str wzr, [x22, #PI4_GENET_RING_START_ADDR]
    str wzr, [x22, #PI4_GENET_RING_START_ADDR_HI]
    str wzr, [x22, #PI4_GENET_RING_READ_PTR]
    str wzr, [x22, #PI4_GENET_RING_READ_PTR_HI]
    str wzr, [x22, #PI4_GENET_RING_WRITE_PTR]
    str wzr, [x22, #PI4_GENET_RING_WRITE_PTR_HI]
    ldr w0, =PI4_GENET_DMA_TX_RING_END_WORD
    str w0, [x22, #PI4_GENET_RING_END_ADDR]
    str wzr, [x22, #PI4_GENET_RING_END_ADDR_HI]

    add x22, x20, #PI4_GENET_DMA_DESC_TOTAL_BYTES
    add x22, x22, #PI4_GENET_DMA_RINGS_BYTES
    mov w0, #PI4_GENET_DMA_BURST_BCM2711
    str w0, [x22, #PI4_GENET_DMA_SCB_BURST_SIZE]
    mov w0, #1
    str w0, [x22, #PI4_GENET_DMA_RING_CFG]
    mov w0, #PI4_GENET_DMA_RING_ENABLE_VALUE
    str w0, [x22, #PI4_GENET_DMA_CTRL]
    ldr w0, [x22, #PI4_GENET_DMA_CTRL]
    adr x1, pi4_net_status_rdma_ctrl
    str x0, [x1]
    ldr w0, [x22, #PI4_GENET_DMA_STATUS]
    adr x1, pi4_net_status_rdma_status
    str x0, [x1]

    add x22, x21, #PI4_GENET_DMA_DESC_TOTAL_BYTES
    add x22, x22, #PI4_GENET_DMA_RINGS_BYTES
    mov w0, #PI4_GENET_DMA_BURST_BCM2711
    str w0, [x22, #PI4_GENET_DMA_SCB_BURST_SIZE]
    mov w0, #PI4_GENET_DMA_ARBITER_SP
    str w0, [x22, #PI4_GENET_DMA_ARB_CTRL]
    mov w0, #1
    str w0, [x22, #PI4_GENET_DMA_PRIORITY_0]
    str w0, [x22, #PI4_GENET_DMA_RING_CFG]
    mov w0, #PI4_GENET_DMA_RING_ENABLE_VALUE
    str w0, [x22, #PI4_GENET_DMA_CTRL]
    ldr w0, [x22, #PI4_GENET_DMA_CTRL]
    adr x1, pi4_net_status_tdma_ctrl
    str x0, [x1]
    ldr w0, [x22, #PI4_GENET_DMA_STATUS]
    adr x1, pi4_net_status_tdma_status
    str x0, [x1]

    adr x0, pi4_net_status_rx_cons
    str xzr, [x0]
    adr x0, pi4_net_status_tx_prod
    str xzr, [x0]

    ldr w0, [x19, #(PI4_GENET_EXT_OFF + PI4_GENET_EXT_RGMII_OOB_CTRL)]
    bic w0, w0, #PI4_GENET_RGMII_OOB_DISABLE
    orr w0, w0, #PI4_GENET_RGMII_MODE_EN
    orr w0, w0, #PI4_GENET_RGMII_LINK
    str w0, [x19, #(PI4_GENET_EXT_OFF + PI4_GENET_EXT_RGMII_OOB_CTRL)]
    ldr w0, [x19, #(PI4_GENET_EXT_OFF + PI4_GENET_EXT_RGMII_OOB_CTRL)]
    adr x1, pi4_net_status_rgmii_oob
    str x0, [x1]

    ldr w0, [x19, #(PI4_GENET_UMAC_OFF + PI4_GENET_UMAC_CMD)]
    adr x1, pi4_net_status_umac_cmd_before
    str x0, [x1]
    bic w0, w0, #PI4_GENET_CMD_SW_RESET
    bic w0, w0, #(3 << 2)
    ldr w1, =(PI4_GENET_CMD_TX_EN | PI4_GENET_CMD_RX_EN | PI4_GENET_CMD_SPEED_1000)
    orr w0, w0, w1
    adr x1, pi4_net_status_umac_cmd_write
    str x0, [x1]
    str w0, [x19, #(PI4_GENET_UMAC_OFF + PI4_GENET_UMAC_CMD)]
    dsb sy
    ldr w0, [x19, #(PI4_GENET_UMAC_OFF + PI4_GENET_UMAC_CMD)]
    adr x1, pi4_net_status_umac_cmd_after
    str x0, [x1]
    adr x1, pi4_net_status_umac_cmd
    str x0, [x1]

    dsb sy
    mov x0, xzr

    ldr x25, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #80
    ret
.size pi4_net_init_dma_static_ipv4, . - pi4_net_init_dma_static_ipv4

.type pi4_net_init_hfb_default_ring0, %function
pi4_net_init_hfb_default_ring0:
    add x0, x19, #PI4_GENET_HFB_OFF
    mov x1, #128
.Lpi4_net_hfb_clear_filter0:
    str wzr, [x0], #4
    subs x1, x1, #1
    b.ne .Lpi4_net_hfb_clear_filter0

    add x0, x19, #PI4_GENET_RDMA_OFF
    add x0, x0, #PI4_GENET_DMA_DESC_TOTAL_BYTES
    add x0, x0, #PI4_GENET_DMA_RINGS_BYTES
    str wzr, [x0, #PI4_GENET_DMA_INDEX2RING_0]

    mov x0, #PI4_GENET_HFB_REG_OFF
    add x0, x19, x0
    str wzr, [x0, #PI4_GENET_HFB_CTRL]
    str wzr, [x0, #PI4_GENET_HFB_FLT_ENABLE_LO]
    str wzr, [x0, #PI4_GENET_HFB_FLT_ENABLE_HI]
    mov w1, #4
    str w1, [x0, #PI4_GENET_HFB_FILTER0_LEN]
    mov w1, #1
    str w1, [x0, #PI4_GENET_HFB_FLT_ENABLE_HI]
    mov w1, #PI4_GENET_RBUF_HFB_EN
    str w1, [x0, #PI4_GENET_HFB_CTRL]
    ldr w1, [x0, #PI4_GENET_HFB_CTRL]
    adr x2, pi4_net_status_hfb_ctrl
    str x1, [x2]
    ret
.size pi4_net_init_hfb_default_ring0, . - pi4_net_init_hfb_default_ring0

.type pi4_net_zero_region, %function
pi4_net_zero_region:
    cbz x1, .Lpi4_net_zero_done
.Lpi4_net_zero_next:
    str xzr, [x0], #8
    subs x1, x1, #8
    b.hi .Lpi4_net_zero_next
.Lpi4_net_zero_done:
    ret
.size pi4_net_zero_region, . - pi4_net_zero_region

.type pi4_net_zero_bytes, %function
pi4_net_zero_bytes:
    cbz x1, .Lpi4_net_zero_bytes_done
.Lpi4_net_zero_bytes_next:
    strb wzr, [x0], #1
    subs x1, x1, #1
    b.ne .Lpi4_net_zero_bytes_next
.Lpi4_net_zero_bytes_done:
    ret
.size pi4_net_zero_bytes, . - pi4_net_zero_bytes

.type pi4_net_clean_dcache_range, %function
pi4_net_clean_dcache_range:
    cbz x1, .Lpi4_net_clean_done
    add x2, x0, x1
    bic x0, x0, #(PI4_NET_CACHE_LINE_BYTES - 1)
.Lpi4_net_clean_next:
    dc cvac, x0
    add x0, x0, #PI4_NET_CACHE_LINE_BYTES
    cmp x0, x2
    b.lo .Lpi4_net_clean_next
    dsb sy
.Lpi4_net_clean_done:
    ret
.size pi4_net_clean_dcache_range, . - pi4_net_clean_dcache_range

.type pi4_net_invalidate_dcache_range, %function
pi4_net_invalidate_dcache_range:
    cbz x1, .Lpi4_net_invalidate_done
    add x2, x0, x1
    bic x0, x0, #(PI4_NET_CACHE_LINE_BYTES - 1)
.Lpi4_net_invalidate_next:
    dc ivac, x0
    add x0, x0, #PI4_NET_CACHE_LINE_BYTES
    cmp x0, x2
    b.lo .Lpi4_net_invalidate_next
    dsb sy
.Lpi4_net_invalidate_done:
    ret
.size pi4_net_invalidate_dcache_range, . - pi4_net_invalidate_dcache_range

.type pi4_net_clean_invalidate_dcache_range, %function
pi4_net_clean_invalidate_dcache_range:
    cbz x1, .Lpi4_net_clean_invalidate_done
    add x2, x0, x1
    bic x0, x0, #(PI4_NET_CACHE_LINE_BYTES - 1)
.Lpi4_net_clean_invalidate_next:
    dc civac, x0
    add x0, x0, #PI4_NET_CACHE_LINE_BYTES
    cmp x0, x2
    b.lo .Lpi4_net_clean_invalidate_next
    dsb sy
.Lpi4_net_clean_invalidate_done:
    ret
.size pi4_net_clean_invalidate_dcache_range, . - pi4_net_clean_invalidate_dcache_range

.type pi4_net_poll_one_packet, %function
pi4_net_poll_one_packet:
    stp x29, x30, [sp, #-80]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    str x25, [sp, #64]

    ldr x19, =PI4_NET_GENET_ARM_BASE
    add x20, x19, #PI4_GENET_RDMA_OFF
    add x20, x20, #PI4_GENET_DMA_DESC_TOTAL_BYTES
    ldr w21, [x20, #PI4_GENET_RDMA_PROD_INDEX]
    and x21, x21, #0xffff
    adr x0, pi4_net_status_rx_prod
    str x21, [x0]
    adr x0, pi4_net_status_rx_cons
    ldr x22, [x0]
    and x22, x22, #0xffff
    cmp x21, x22
    b.eq .Lpi4_net_poll_done

    and x23, x22, #PI4_NET_RX_RING_INDEX_MASK
    ldr x24, =pi4_net_rx_buffers
    add x24, x24, x23, lsl #11
    mov x0, x24
    mov x1, #PI4_NET_RX_BUF_BYTES
    bl pi4_net_invalidate_dcache_range
    ldr w25, [x24]
    adr x0, pi4_net_status_rx_length_status
    str x25, [x0]
    add x0, x24, #PI4_NET_RX_FRAME_OFFSET
    bl pi4_net_handle_frame

    add x22, x22, #1
    and x22, x22, #0xffff
    adr x0, pi4_net_status_rx_cons
    str x22, [x0]
    str w22, [x20, #PI4_GENET_RDMA_CONS_INDEX]
    adr x0, pi4_net_status_rx_packets
    ldr x1, [x0]
    add x1, x1, #1
    str x1, [x0]

.Lpi4_net_poll_done:
    ldr x25, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #80
    ret
.size pi4_net_poll_one_packet, . - pi4_net_poll_one_packet

.type pi4_net_handle_frame, %function
pi4_net_handle_frame:
    stp x29, x30, [sp, #-48]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    str x21, [sp, #32]
    mov x19, x0

    ldrb w0, [x19, #12]
    ldrb w1, [x19, #13]
    lsl w0, w0, #8
    orr w0, w0, w1
    cmp w0, #PI4_NET_ETH_TYPE_ARP
    b.eq .Lpi4_net_handle_arp
    cmp w0, #PI4_NET_ETH_TYPE_IPV4
    b.eq .Lpi4_net_handle_ipv4
    b .Lpi4_net_handle_done

.Lpi4_net_handle_arp:
    ldrb w0, [x19, #20]
    ldrb w1, [x19, #21]
    lsl w0, w0, #8
    orr w0, w0, w1
    adr x1, pi4_net_status_arp_last_op
    str x0, [x1]
    cmp w0, #PI4_NET_ARP_OP_REQUEST
    b.ne .Lpi4_net_handle_done
    add x0, x19, #38
    bl pi4_net_is_local_ip
    cbz x0, .Lpi4_net_handle_done
    mov x0, x19
    bl pi4_net_send_arp_reply
    b .Lpi4_net_handle_done

.Lpi4_net_handle_ipv4:
    ldrb w0, [x19, #14]
    cmp w0, #0x45
    b.ne .Lpi4_net_handle_done
    add x0, x19, #30
    bl pi4_net_is_local_ip
    cbz x0, .Lpi4_net_handle_done
    ldrb w0, [x19, #23]
    cmp w0, #PI4_NET_IPV4_PROTO_ICMP
    b.eq .Lpi4_net_handle_icmp
    cmp w0, #PI4_NET_IPV4_PROTO_TCP
    b.eq .Lpi4_net_handle_tcp
    b .Lpi4_net_handle_done

.Lpi4_net_handle_icmp:
    ldrb w0, [x19, #34]
    cmp w0, #PI4_NET_ICMP_ECHO_REQUEST
    b.ne .Lpi4_net_handle_done
    mov x0, x19
    bl pi4_net_send_icmp_echo_reply
    b .Lpi4_net_handle_done

.Lpi4_net_handle_tcp:
    mov x0, x19
    bl pi4_net_handle_tcp_frame

.Lpi4_net_handle_done:
    ldr x21, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #48
    ret
.size pi4_net_handle_frame, . - pi4_net_handle_frame

.type pi4_net_send_arp_reply, %function
pi4_net_send_arp_reply:
    stp x29, x30, [sp, #-64]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    str x23, [sp, #48]
    mov x19, x0

    bl pi4_net_prepare_tx_buffer
    mov x20, x0

    mov x0, x20
    add x1, x19, #22
    bl pi4_net_copy6
    add x0, x20, #6
    bl pi4_net_store_local_mac
    mov w0, #0x08
    strb w0, [x20, #12]
    mov w0, #0x06
    strb w0, [x20, #13]

    mov w0, #0x00
    strb w0, [x20, #14]
    mov w0, #0x01
    strb w0, [x20, #15]
    mov w0, #0x08
    strb w0, [x20, #16]
    mov w0, #0x00
    strb w0, [x20, #17]
    mov w0, #0x06
    strb w0, [x20, #18]
    mov w0, #0x04
    strb w0, [x20, #19]
    mov w0, #0x00
    strb w0, [x20, #20]
    mov w0, #0x02
    strb w0, [x20, #21]
    add x0, x20, #22
    bl pi4_net_store_local_mac
    add x0, x20, #28
    bl pi4_net_store_local_ip
    add x0, x20, #32
    add x1, x19, #22
    bl pi4_net_copy6
    add x0, x20, #38
    add x1, x19, #28
    bl pi4_net_copy4

    mov x0, x20
    mov x1, #42
    bl pi4_net_submit_tx
    adr x0, pi4_net_status_arp_replies
    ldr x1, [x0]
    add x1, x1, #1
    str x1, [x0]

    ldr x23, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret
.size pi4_net_send_arp_reply, . - pi4_net_send_arp_reply

.type pi4_net_send_gratuitous_arp, %function
pi4_net_send_gratuitous_arp:
    stp x29, x30, [sp, #-32]!
    mov x29, sp
    str x19, [sp, #16]

    bl pi4_net_prepare_tx_buffer
    mov x19, x0

    mov w0, #0xff
    strb w0, [x19]
    strb w0, [x19, #1]
    strb w0, [x19, #2]
    strb w0, [x19, #3]
    strb w0, [x19, #4]
    strb w0, [x19, #5]
    add x0, x19, #6
    bl pi4_net_store_local_mac
    mov w0, #0x08
    strb w0, [x19, #12]
    mov w0, #0x06
    strb w0, [x19, #13]

    mov w0, #0x00
    strb w0, [x19, #14]
    mov w0, #0x01
    strb w0, [x19, #15]
    mov w0, #0x08
    strb w0, [x19, #16]
    mov w0, #0x00
    strb w0, [x19, #17]
    mov w0, #0x06
    strb w0, [x19, #18]
    mov w0, #0x04
    strb w0, [x19, #19]
    mov w0, #0x00
    strb w0, [x19, #20]
    mov w0, #0x02
    strb w0, [x19, #21]
    add x0, x19, #22
    bl pi4_net_store_local_mac
    add x0, x19, #28
    bl pi4_net_store_local_ip
    add x0, x19, #32
    bl pi4_net_store_local_mac
    add x0, x19, #38
    bl pi4_net_store_local_ip

    mov x0, x19
    mov x1, #42
    bl pi4_net_submit_tx
    adr x0, pi4_net_status_gratuitous_arps
    ldr x1, [x0]
    add x1, x1, #1
    str x1, [x0]

    ldr x19, [sp, #16]
    ldp x29, x30, [sp], #32
    ret
.size pi4_net_send_gratuitous_arp, . - pi4_net_send_gratuitous_arp

.type pi4_net_send_udp_probe, %function
pi4_net_send_udp_probe:
    stp x29, x30, [sp, #-32]!
    mov x29, sp
    str x19, [sp, #16]

    bl pi4_net_prepare_tx_buffer
    mov x19, x0

    mov w0, #0xff
    strb w0, [x19]
    strb w0, [x19, #1]
    strb w0, [x19, #2]
    strb w0, [x19, #3]
    strb w0, [x19, #4]
    strb w0, [x19, #5]
    add x0, x19, #6
    bl pi4_net_store_local_mac
    mov w0, #0x08
    strb w0, [x19, #12]
    mov w0, #0x00
    strb w0, [x19, #13]

    mov w0, #0x45
    strb w0, [x19, #14]
    strb wzr, [x19, #15]
    add x0, x19, #16
    mov x1, #PI4_NET_UDP_IP_LEN
    bl pi4_net_store_be16
    strb wzr, [x19, #18]
    strb wzr, [x19, #19]
    mov w0, #0x40
    strb w0, [x19, #20]
    strb wzr, [x19, #21]
    mov w0, #64
    strb w0, [x19, #22]
    mov w0, #PI4_NET_IPV4_PROTO_UDP
    strb w0, [x19, #23]
    strb wzr, [x19, #24]
    strb wzr, [x19, #25]
    add x0, x19, #26
    bl pi4_net_store_local_ip
    mov w0, #PI4_NET_HOST_IP0
    strb w0, [x19, #30]
    mov w0, #PI4_NET_HOST_IP1
    strb w0, [x19, #31]
    mov w0, #PI4_NET_HOST_IP2
    strb w0, [x19, #32]
    mov w0, #255
    strb w0, [x19, #33]

    add x0, x19, #34
    mov x1, #PI4_NET_TCP_LISTEN_PORT
    bl pi4_net_store_be16
    add x0, x19, #36
    mov x1, #PI4_NET_UDP_PROBE_PORT
    bl pi4_net_store_be16
    add x0, x19, #38
    mov x1, #(8 + PI4_NET_UDP_PROBE_LEN)
    bl pi4_net_store_be16
    strb wzr, [x19, #40]
    strb wzr, [x19, #41]
    add x0, x19, #42
    ldr x1, =pi4_net_udp_probe_payload
    mov x2, #PI4_NET_UDP_PROBE_LEN
    bl pi4_net_copy_bytes

    add x0, x19, #14
    mov x1, #20
    bl pi4_net_checksum16
    lsr w1, w0, #8
    strb w1, [x19, #24]
    strb w0, [x19, #25]

    mov x0, x19
    mov x1, #PI4_NET_UDP_FRAME_LEN
    bl pi4_net_submit_tx
    adr x0, pi4_net_status_udp_probes
    ldr x1, [x0]
    add x1, x1, #1
    str x1, [x0]

    ldr x19, [sp, #16]
    ldp x29, x30, [sp], #32
    ret
.size pi4_net_send_udp_probe, . - pi4_net_send_udp_probe

.type pi4_net_send_icmp_echo_reply, %function
pi4_net_send_icmp_echo_reply:
    stp x29, x30, [sp, #-80]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    str x25, [sp, #64]
    mov x19, x0

    ldrb w21, [x19, #16]
    ldrb w0, [x19, #17]
    lsl w21, w21, #8
    orr w21, w21, w0
    cmp x21, #28
    b.lo .Lpi4_net_send_icmp_done
    add x22, x21, #14
    cmp x22, #PI4_NET_MAX_FRAME_BYTES
    b.hi .Lpi4_net_send_icmp_done

    bl pi4_net_prepare_tx_buffer
    mov x20, x0
    mov x0, x20
    mov x1, x19
    mov x2, x22
    bl pi4_net_copy_bytes

    mov x0, x20
    add x1, x20, #6
    bl pi4_net_copy6
    add x0, x20, #6
    bl pi4_net_store_local_mac

    add x0, x20, #30
    add x1, x20, #26
    bl pi4_net_copy4
    add x0, x20, #26
    bl pi4_net_store_local_ip

    mov w0, #64
    strb w0, [x20, #22]
    strb wzr, [x20, #24]
    strb wzr, [x20, #25]
    strb wzr, [x20, #34]
    strb wzr, [x20, #35]
    strb wzr, [x20, #36]
    strb wzr, [x20, #37]

    add x0, x20, #14
    mov x1, #20
    bl pi4_net_checksum16
    lsr w1, w0, #8
    strb w1, [x20, #24]
    strb w0, [x20, #25]

    add x0, x20, #34
    sub x1, x21, #20
    bl pi4_net_checksum16
    lsr w1, w0, #8
    strb w1, [x20, #36]
    strb w0, [x20, #37]

    mov x0, x20
    mov x1, x22
    bl pi4_net_submit_tx
    adr x0, pi4_net_status_icmp_replies
    ldr x1, [x0]
    add x1, x1, #1
    str x1, [x0]

.Lpi4_net_send_icmp_done:
    ldr x25, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #80
    ret
.size pi4_net_send_icmp_echo_reply, . - pi4_net_send_icmp_echo_reply

.type pi4_net_handle_tcp_frame, %function
pi4_net_handle_tcp_frame:
    stp x29, x30, [sp, #-48]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    str x21, [sp, #32]
    mov x19, x0

    ldrb w20, [x19, #16]
    ldrb w0, [x19, #17]
    lsl w20, w20, #8
    orr w20, w20, w0
    cmp x20, #40
    b.lo .Lpi4_net_tcp_done
    ldrb w0, [x19, #46]
    lsr w0, w0, #4
    cmp w0, #5
    b.lo .Lpi4_net_tcp_done

    add x0, x19, #34
    bl pi4_net_load_be16
    adr x1, pi4_net_status_tcp_src_port
    str x0, [x1]
    add x0, x19, #36
    bl pi4_net_load_be16
    adr x1, pi4_net_status_tcp_dst_port
    str x0, [x1]
    cmp x0, #PI4_NET_TCP_LISTEN_PORT
    b.ne .Lpi4_net_tcp_done

    add x0, x19, #38
    bl pi4_net_load_be32
    adr x1, pi4_net_status_tcp_last_seq
    str x0, [x1]
    add x0, x19, #42
    bl pi4_net_load_be32
    adr x1, pi4_net_status_tcp_last_ack
    str x0, [x1]
    ldrb w21, [x19, #47]
    adr x1, pi4_net_status_tcp_last_flags
    str x21, [x1]

    tst w21, #PI4_NET_TCP_FLAG_SYN
    b.eq .Lpi4_net_tcp_check_ack
    adr x0, pi4_net_status_tcp_syns
    ldr x1, [x0]
    add x1, x1, #1
    str x1, [x0]
    mov x0, x19
    bl pi4_net_send_tcp_syn_ack
    b .Lpi4_net_tcp_done

.Lpi4_net_tcp_check_ack:
    tst w21, #PI4_NET_TCP_FLAG_ACK
    b.eq .Lpi4_net_tcp_done
    mov x0, x19
    bl pi4_net_record_ssh_client_payload
    adr x0, pi4_net_status_tcp_banners
    ldr x1, [x0]
    cbnz x1, .Lpi4_net_tcp_ack_client_payload
    mov x0, x19
    bl pi4_net_send_tcp_banner
    mov x0, x19
    bl pi4_net_send_tcp_kexinit
    b .Lpi4_net_tcp_done

.Lpi4_net_tcp_ack_client_payload:
    mov x0, x19
    bl pi4_net_send_tcp_ack_only

.Lpi4_net_tcp_done:
    ldr x21, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #48
    ret
.size pi4_net_handle_tcp_frame, . - pi4_net_handle_tcp_frame

.type pi4_net_send_tcp_syn_ack, %function
pi4_net_send_tcp_syn_ack:
    stp x29, x30, [sp, #-64]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    str x23, [sp, #48]
    mov x19, x0

    add x0, x19, #38
    bl pi4_net_load_be32
    add x21, x0, #1
    bl pi4_net_prepare_tx_buffer
    mov x20, x0
    mov x0, x20
    mov x1, x19
    mov x2, xzr
    mov x3, #(PI4_NET_TCP_FLAG_SYN | PI4_NET_TCP_FLAG_ACK)
    ldr x4, =PI4_NET_TCP_SERVER_SEQ
    mov x5, x21
    bl pi4_net_build_tcp_reply_base
    mov x21, x0
    mov x22, x1
    mov x0, x20
    mov x1, x22
    bl pi4_net_finish_tcp_reply
    mov x0, x20
    mov x1, x21
    bl pi4_net_submit_tx
    adr x0, pi4_net_status_tcp_synacks
    ldr x1, [x0]
    add x1, x1, #1
    str x1, [x0]

    ldr x23, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret
.size pi4_net_send_tcp_syn_ack, . - pi4_net_send_tcp_syn_ack

.type pi4_net_send_tcp_banner, %function
pi4_net_send_tcp_banner:
    stp x29, x30, [sp, #-80]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    str x25, [sp, #64]
    mov x19, x0

    ldrb w21, [x19, #16]
    ldrb w0, [x19, #17]
    lsl w21, w21, #8
    orr w21, w21, w0
    ldrb w22, [x19, #46]
    lsr w22, w22, #4
    lsl w22, w22, #2
    sub x23, x21, #20
    cmp x23, x22
    b.lo .Lpi4_net_tcp_banner_done
    sub x23, x23, x22
    add x0, x19, #38
    bl pi4_net_load_be32
    add x24, x0, x23

    bl pi4_net_prepare_tx_buffer
    mov x20, x0
    mov x0, x20
    mov x1, x19
    mov x2, #PI4_NET_SSH_BANNER_LEN
    mov x3, #(PI4_NET_TCP_FLAG_PSH | PI4_NET_TCP_FLAG_ACK)
    ldr x4, =(PI4_NET_TCP_SERVER_SEQ + 1)
    mov x5, x24
    bl pi4_net_build_tcp_reply_base
    mov x21, x0
    mov x22, x1
    add x0, x20, #54
    ldr x1, =pi4_net_ssh_banner
    mov x2, #PI4_NET_SSH_BANNER_LEN
    bl pi4_net_copy_bytes
    mov x0, x20
    mov x1, x22
    bl pi4_net_finish_tcp_reply
    mov x0, x20
    mov x1, x21
    bl pi4_net_submit_tx
    adr x0, pi4_net_status_tcp_banners
    ldr x1, [x0]
    add x1, x1, #1
    str x1, [x0]

.Lpi4_net_tcp_banner_done:
    ldr x25, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #80
    ret
.size pi4_net_send_tcp_banner, . - pi4_net_send_tcp_banner

.type pi4_net_send_tcp_kexinit, %function
pi4_net_send_tcp_kexinit:
    stp x29, x30, [sp, #-80]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    str x25, [sp, #64]
    mov x19, x0

    ldrb w21, [x19, #16]
    ldrb w0, [x19, #17]
    lsl w21, w21, #8
    orr w21, w21, w0
    ldrb w22, [x19, #46]
    lsr w22, w22, #4
    lsl w22, w22, #2
    sub x23, x21, #20
    cmp x23, x22
    b.lo .Lpi4_net_tcp_kexinit_done
    sub x23, x23, x22
    add x0, x19, #38
    bl pi4_net_load_be32
    add x24, x0, x23

    bl pi4_net_prepare_tx_buffer
    mov x20, x0
    mov x0, x20
    mov x1, x19
    mov x2, #PI4_NET_SSH_KEXINIT_PACKET_LEN
    mov x3, #(PI4_NET_TCP_FLAG_PSH | PI4_NET_TCP_FLAG_ACK)
    ldr x4, =(PI4_NET_TCP_SERVER_SEQ + 1 + PI4_NET_SSH_BANNER_LEN)
    mov x5, x24
    bl pi4_net_build_tcp_reply_base
    mov x21, x0
    mov x22, x1
    add x0, x20, #54
    ldr x1, =pi4_net_ssh_kexinit_packet
    mov x2, #PI4_NET_SSH_KEXINIT_PACKET_LEN
    bl pi4_net_copy_bytes
    mov x0, x20
    mov x1, x22
    bl pi4_net_finish_tcp_reply
    mov x0, x20
    mov x1, x21
    bl pi4_net_submit_tx

.Lpi4_net_tcp_kexinit_done:
    ldr x25, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #80
    ret
.size pi4_net_send_tcp_kexinit, . - pi4_net_send_tcp_kexinit

.type pi4_net_send_tcp_ack_only, %function
pi4_net_send_tcp_ack_only:
    stp x29, x30, [sp, #-80]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    str x25, [sp, #64]
    mov x19, x0

    ldrb w21, [x19, #16]
    ldrb w0, [x19, #17]
    lsl w21, w21, #8
    orr w21, w21, w0
    ldrb w22, [x19, #46]
    lsr w22, w22, #4
    lsl w22, w22, #2
    sub x23, x21, #20
    cmp x23, x22
    b.lo .Lpi4_net_tcp_ack_only_done
    sub x23, x23, x22
    add x0, x19, #38
    bl pi4_net_load_be32
    add x24, x0, x23

    bl pi4_net_prepare_tx_buffer
    mov x20, x0
    mov x0, x20
    mov x1, x19
    mov x2, xzr
    mov x3, #PI4_NET_TCP_FLAG_ACK
    ldr x4, =(PI4_NET_TCP_SERVER_SEQ + 1 + PI4_NET_SSH_BANNER_LEN + PI4_NET_SSH_KEXINIT_PACKET_LEN)
    mov x5, x24
    bl pi4_net_build_tcp_reply_base
    mov x21, x0
    mov x22, x1
    mov x0, x20
    mov x1, x22
    bl pi4_net_finish_tcp_reply
    mov x0, x20
    mov x1, x21
    bl pi4_net_submit_tx

.Lpi4_net_tcp_ack_only_done:
    ldr x25, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #80
    ret
.size pi4_net_send_tcp_ack_only, . - pi4_net_send_tcp_ack_only

.type pi4_net_record_ssh_client_payload, %function
pi4_net_record_ssh_client_payload:
    stp x29, x30, [sp, #-64]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    str x23, [sp, #48]
    mov x19, x0

    ldrb w20, [x19, #16]
    ldrb w0, [x19, #17]
    lsl w20, w20, #8
    orr w20, w20, w0
    cmp x20, #40
    b.lo .Lpi4_net_record_ssh_done
    ldrb w21, [x19, #46]
    lsr w21, w21, #4
    lsl w21, w21, #2
    sub x22, x20, #20
    cmp x22, x21
    b.lo .Lpi4_net_record_ssh_done
    sub x22, x22, x21
    cbz x22, .Lpi4_net_record_ssh_done
    add x23, x19, #34
    add x23, x23, x21
    cmp x22, #4
    b.hs .Lpi4_net_record_ssh_check_client_id

.Lpi4_net_record_ssh_check_binary:
    cmp x22, #6
    b.lo .Lpi4_net_record_ssh_done

    mov x0, x23
    bl pi4_net_load_be32
    mov x20, x0
    ldrb w21, [x23, #5]
    lsl x1, x21, #32
    orr x1, x1, x20
    adr x0, pi4_net_status_tcp_checksum
    str x1, [x0]
    b .Lpi4_net_record_ssh_done

.Lpi4_net_record_ssh_check_client_id:
    ldrb w0, [x23]
    cmp w0, #'S'
    b.ne .Lpi4_net_record_ssh_check_binary
    ldrb w0, [x23, #1]
    cmp w0, #'S'
    b.ne .Lpi4_net_record_ssh_check_binary
    ldrb w0, [x23, #2]
    cmp w0, #'H'
    b.ne .Lpi4_net_record_ssh_check_binary
    ldrb w0, [x23, #3]
    cmp w0, #'-'
    b.ne .Lpi4_net_record_ssh_check_binary
    ldr x1, =0x5353482d
    adr x0, pi4_net_status_tcp_checksum
    str x1, [x0]

.Lpi4_net_record_ssh_done:
    ldr x23, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret
.size pi4_net_record_ssh_client_payload, . - pi4_net_record_ssh_client_payload

.type pi4_net_build_tcp_reply_base, %function
pi4_net_build_tcp_reply_base:
    stp x29, x30, [sp, #-96]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    str x27, [sp, #80]
    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, x3
    mov x23, x4
    mov x24, x5
    add x25, x21, #20
    add x26, x25, #20

    mov x0, x19
    add x1, x20, #6
    bl pi4_net_copy6
    add x0, x19, #6
    bl pi4_net_store_local_mac
    mov w0, #0x08
    strb w0, [x19, #12]
    mov w0, #0x00
    strb w0, [x19, #13]

    mov w0, #0x45
    strb w0, [x19, #14]
    strb wzr, [x19, #15]
    add x0, x19, #16
    mov x1, x26
    bl pi4_net_store_be16
    strb wzr, [x19, #18]
    strb wzr, [x19, #19]
    mov w0, #0x40
    strb w0, [x19, #20]
    strb wzr, [x19, #21]
    mov w0, #64
    strb w0, [x19, #22]
    mov w0, #PI4_NET_IPV4_PROTO_TCP
    strb w0, [x19, #23]
    strb wzr, [x19, #24]
    strb wzr, [x19, #25]
    add x0, x19, #26
    bl pi4_net_store_local_ip
    add x0, x19, #30
    add x1, x20, #26
    bl pi4_net_copy4

    add x0, x19, #34
    mov x1, #PI4_NET_TCP_LISTEN_PORT
    bl pi4_net_store_be16
    add x0, x19, #36
    add x1, x20, #34
    bl pi4_net_copy2
    add x0, x19, #38
    mov x1, x23
    bl pi4_net_store_be32
    add x0, x19, #42
    mov x1, x24
    bl pi4_net_store_be32
    mov w0, #0x50
    strb w0, [x19, #46]
    strb w22, [x19, #47]
    mov w0, #0x40
    strb w0, [x19, #48]
    strb wzr, [x19, #49]
    strb wzr, [x19, #50]
    strb wzr, [x19, #51]
    strb wzr, [x19, #52]
    strb wzr, [x19, #53]

    add x0, x26, #14
    mov x1, x25
    ldr x27, [sp, #80]
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #96
    ret
.size pi4_net_build_tcp_reply_base, . - pi4_net_build_tcp_reply_base

.type pi4_net_finish_tcp_reply, %function
pi4_net_finish_tcp_reply:
    stp x29, x30, [sp, #-32]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    mov x19, x0
    mov x20, x1

    add x0, x19, #14
    mov x1, #20
    bl pi4_net_checksum16
    lsr w1, w0, #8
    strb w1, [x19, #24]
    strb w0, [x19, #25]

    mov x0, x19
    mov x1, x20
    bl pi4_net_tcp_checksum
    adr x2, pi4_net_status_tcp_checksum
    str x0, [x2]
    lsr w1, w0, #8
    strb w1, [x19, #50]
    strb w0, [x19, #51]

    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret
.size pi4_net_finish_tcp_reply, . - pi4_net_finish_tcp_reply

.type pi4_net_prepare_tx_buffer, %function
pi4_net_prepare_tx_buffer:
    adr x0, pi4_net_status_tx_prod
    ldr x1, [x0]
    and x1, x1, #PI4_NET_TX_RING_INDEX_MASK
    ldr x0, =pi4_net_tx_buffers
    add x0, x0, x1, lsl #11
    add x0, x0, #PI4_NET_TX_TSB_BYTES
    ret
.size pi4_net_prepare_tx_buffer, . - pi4_net_prepare_tx_buffer

.type pi4_net_submit_tx, %function
pi4_net_submit_tx:
    stp x29, x30, [sp, #-64]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    str x23, [sp, #48]
    mov x19, x0
    mov x20, x1

    cmp x20, #PI4_NET_MIN_FRAME_BYTES
    b.hs .Lpi4_net_submit_no_pad
    add x0, x19, x20
    mov x1, #PI4_NET_MIN_FRAME_BYTES
    sub x1, x1, x20
    bl pi4_net_zero_bytes
    mov x20, #PI4_NET_MIN_FRAME_BYTES
.Lpi4_net_submit_no_pad:
    adr x0, pi4_net_status_tx_prod
    ldr x21, [x0]
    and x22, x21, #PI4_NET_TX_RING_INDEX_MASK
    ldr x23, =PI4_NET_GENET_ARM_BASE
    add x23, x23, #PI4_GENET_TDMA_OFF
    sub x0, x19, #PI4_NET_TX_TSB_BYTES
    mov x1, #PI4_NET_TX_TSB_BYTES
    bl pi4_net_zero_region
    sub x0, x19, #PI4_NET_TX_TSB_BYTES
    add x1, x20, #PI4_NET_TX_TSB_BYTES
    mov x20, x1
    mov x19, x0
    mov x0, x19
    mov x1, x20
    bl pi4_net_clean_dcache_range
    mov x0, #PI4_GENET_DMA_DESC_BYTES
    mul x1, x22, x0
    add x22, x23, x1
    lsl w2, w20, #PI4_GENET_DMA_BUFLENGTH_SHIFT
    mov w3, #(PI4_GENET_DMA_SOP | PI4_GENET_DMA_EOP | PI4_GENET_DMA_TX_APPEND_CRC | PI4_GENET_DMA_TX_QTAG_VALUE)
    orr w2, w2, w3
    str w19, [x22, #PI4_GENET_DMA_DESC_ADDRESS_LO]
    str wzr, [x22, #PI4_GENET_DMA_DESC_ADDRESS_HI]
    str w2, [x22, #PI4_GENET_DMA_DESC_LENGTH_STATUS]
    dsb sy

    add x21, x21, #1
    and x21, x21, #0xffff
    adr x0, pi4_net_status_tx_prod
    str x21, [x0]
    add x3, x23, #PI4_GENET_DMA_DESC_TOTAL_BYTES
    str w21, [x3, #PI4_GENET_RING_PROD_INDEX]
    ldr w0, [x3, #PI4_GENET_RING_CONS_INDEX]
    adr x1, pi4_net_status_tx_cons_hw
    str x0, [x1]
    ldr w0, [x3, #PI4_GENET_RING_READ_PTR]
    adr x1, pi4_net_status_tx_read_ptr_hw
    str x0, [x1]
    ldr w0, [x3, #PI4_GENET_RING_WRITE_PTR]
    adr x1, pi4_net_status_tx_write_ptr_hw
    str x0, [x1]
    add x4, x23, #PI4_GENET_DMA_DESC_TOTAL_BYTES
    add x4, x4, #PI4_GENET_DMA_RINGS_BYTES
    ldr w0, [x4, #PI4_GENET_DMA_STATUS]
    adr x1, pi4_net_status_tdma_status
    str x0, [x1]
    ldr w0, [x22, #PI4_GENET_DMA_DESC_LENGTH_STATUS]
    adr x1, pi4_net_status_tx_desc_status_hw
    str x0, [x1]
    adr x0, pi4_net_status_tx_length_status
    uxtw x1, w2
    str x1, [x0]
    adr x0, pi4_net_status_tx_packets
    ldr x1, [x0]
    add x1, x1, #1
    str x1, [x0]

    ldr x23, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret
.size pi4_net_submit_tx, . - pi4_net_submit_tx

.type pi4_net_is_local_ip, %function
pi4_net_is_local_ip:
    ldrb w1, [x0]
    cmp w1, #PI4_NET_STATIC_IP0
    b.ne .Lpi4_net_is_local_ip_no
    ldrb w1, [x0, #1]
    cmp w1, #PI4_NET_STATIC_IP1
    b.ne .Lpi4_net_is_local_ip_no
    ldrb w1, [x0, #2]
    cmp w1, #PI4_NET_STATIC_IP2
    b.ne .Lpi4_net_is_local_ip_no
    ldrb w1, [x0, #3]
    cmp w1, #PI4_NET_STATIC_IP3
    b.ne .Lpi4_net_is_local_ip_no
    mov x0, #1
    ret
.Lpi4_net_is_local_ip_no:
    mov x0, xzr
    ret
.size pi4_net_is_local_ip, . - pi4_net_is_local_ip

.type pi4_net_store_local_ip, %function
pi4_net_store_local_ip:
    mov w1, #PI4_NET_STATIC_IP0
    strb w1, [x0]
    mov w1, #PI4_NET_STATIC_IP1
    strb w1, [x0, #1]
    mov w1, #PI4_NET_STATIC_IP2
    strb w1, [x0, #2]
    mov w1, #PI4_NET_STATIC_IP3
    strb w1, [x0, #3]
    ret
.size pi4_net_store_local_ip, . - pi4_net_store_local_ip

.type pi4_net_store_local_mac, %function
pi4_net_store_local_mac:
    mov w1, #PI4_NET_MAC0
    strb w1, [x0]
    mov w1, #PI4_NET_MAC1
    strb w1, [x0, #1]
    mov w1, #PI4_NET_MAC2
    strb w1, [x0, #2]
    mov w1, #PI4_NET_MAC3
    strb w1, [x0, #3]
    mov w1, #PI4_NET_MAC4
    strb w1, [x0, #4]
    mov w1, #PI4_NET_MAC5
    strb w1, [x0, #5]
    ret
.size pi4_net_store_local_mac, . - pi4_net_store_local_mac

.type pi4_net_store_host_ip, %function
pi4_net_store_host_ip:
    mov w1, #PI4_NET_HOST_IP0
    strb w1, [x0]
    mov w1, #PI4_NET_HOST_IP1
    strb w1, [x0, #1]
    mov w1, #PI4_NET_HOST_IP2
    strb w1, [x0, #2]
    mov w1, #PI4_NET_HOST_IP3
    strb w1, [x0, #3]
    ret
.size pi4_net_store_host_ip, . - pi4_net_store_host_ip

.type pi4_net_store_host_mac, %function
pi4_net_store_host_mac:
    mov w1, #PI4_NET_HOST_MAC0
    strb w1, [x0]
    mov w1, #PI4_NET_HOST_MAC1
    strb w1, [x0, #1]
    mov w1, #PI4_NET_HOST_MAC2
    strb w1, [x0, #2]
    mov w1, #PI4_NET_HOST_MAC3
    strb w1, [x0, #3]
    mov w1, #PI4_NET_HOST_MAC4
    strb w1, [x0, #4]
    mov w1, #PI4_NET_HOST_MAC5
    strb w1, [x0, #5]
    ret
.size pi4_net_store_host_mac, . - pi4_net_store_host_mac

.type pi4_net_copy4, %function
pi4_net_copy4:
    ldrb w2, [x1]
    strb w2, [x0]
    ldrb w2, [x1, #1]
    strb w2, [x0, #1]
    ldrb w2, [x1, #2]
    strb w2, [x0, #2]
    ldrb w2, [x1, #3]
    strb w2, [x0, #3]
    ret
.size pi4_net_copy4, . - pi4_net_copy4

.type pi4_net_copy2, %function
pi4_net_copy2:
    ldrb w2, [x1]
    strb w2, [x0]
    ldrb w2, [x1, #1]
    strb w2, [x0, #1]
    ret
.size pi4_net_copy2, . - pi4_net_copy2

.type pi4_net_copy6, %function
pi4_net_copy6:
    ldrb w2, [x1]
    strb w2, [x0]
    ldrb w2, [x1, #1]
    strb w2, [x0, #1]
    ldrb w2, [x1, #2]
    strb w2, [x0, #2]
    ldrb w2, [x1, #3]
    strb w2, [x0, #3]
    ldrb w2, [x1, #4]
    strb w2, [x0, #4]
    ldrb w2, [x1, #5]
    strb w2, [x0, #5]
    ret
.size pi4_net_copy6, . - pi4_net_copy6

.type pi4_net_copy_bytes, %function
pi4_net_copy_bytes:
    cbz x2, .Lpi4_net_copy_bytes_done
.Lpi4_net_copy_bytes_next:
    ldrb w3, [x1], #1
    strb w3, [x0], #1
    subs x2, x2, #1
    b.ne .Lpi4_net_copy_bytes_next
.Lpi4_net_copy_bytes_done:
    ret
.size pi4_net_copy_bytes, . - pi4_net_copy_bytes

.type pi4_net_load_be16, %function
pi4_net_load_be16:
    ldrb w1, [x0]
    ldrb w2, [x0, #1]
    lsl w1, w1, #8
    orr w0, w1, w2
    ret
.size pi4_net_load_be16, . - pi4_net_load_be16

.type pi4_net_load_be32, %function
pi4_net_load_be32:
    ldrb w1, [x0]
    ldrb w2, [x0, #1]
    ldrb w3, [x0, #2]
    ldrb w4, [x0, #3]
    lsl w1, w1, #24
    orr w1, w1, w2, lsl #16
    orr w1, w1, w3, lsl #8
    orr w0, w1, w4
    ret
.size pi4_net_load_be32, . - pi4_net_load_be32

.type pi4_net_store_be16, %function
pi4_net_store_be16:
    lsr w2, w1, #8
    strb w2, [x0]
    strb w1, [x0, #1]
    ret
.size pi4_net_store_be16, . - pi4_net_store_be16

.type pi4_net_store_be32, %function
pi4_net_store_be32:
    lsr w2, w1, #24
    strb w2, [x0]
    lsr w2, w1, #16
    strb w2, [x0, #1]
    lsr w2, w1, #8
    strb w2, [x0, #2]
    strb w1, [x0, #3]
    ret
.size pi4_net_store_be32, . - pi4_net_store_be32

.type pi4_net_checksum16, %function
pi4_net_checksum16:
    mov x2, xzr
.Lpi4_net_checksum_pair:
    cmp x1, #2
    b.lo .Lpi4_net_checksum_tail
    ldrb w3, [x0], #1
    ldrb w4, [x0], #1
    lsl w3, w3, #8
    orr w3, w3, w4
    add x2, x2, x3
    sub x1, x1, #2
    b .Lpi4_net_checksum_pair
.Lpi4_net_checksum_tail:
    cbz x1, .Lpi4_net_checksum_fold
    ldrb w3, [x0]
    lsl w3, w3, #8
    add x2, x2, x3
.Lpi4_net_checksum_fold:
    lsr x3, x2, #16
    and x2, x2, #0xffff
    add x2, x2, x3
    lsr x3, x2, #16
    cbnz x3, .Lpi4_net_checksum_fold
    mvn x0, x2
    and x0, x0, #0xffff
    ret
.size pi4_net_checksum16, . - pi4_net_checksum16

.type pi4_net_sum16_range, %function
pi4_net_sum16_range:
    cbz x1, .Lpi4_net_sum16_done
.Lpi4_net_sum16_pair:
    cmp x1, #2
    b.lo .Lpi4_net_sum16_tail
    ldrb w3, [x0], #1
    ldrb w4, [x0], #1
    lsl w3, w3, #8
    orr w3, w3, w4
    add x2, x2, x3
    sub x1, x1, #2
    b .Lpi4_net_sum16_pair
.Lpi4_net_sum16_tail:
    cbz x1, .Lpi4_net_sum16_done
    ldrb w3, [x0]
    lsl w3, w3, #8
    add x2, x2, x3
.Lpi4_net_sum16_done:
    mov x0, x2
    ret
.size pi4_net_sum16_range, . - pi4_net_sum16_range

.type pi4_net_tcp_checksum, %function
pi4_net_tcp_checksum:
    stp x29, x30, [sp, #-32]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    mov x19, x0
    mov x20, x1

    mov x2, xzr
    add x0, x19, #26
    mov x1, #8
    bl pi4_net_sum16_range
    mov x2, x0
    add x2, x2, #PI4_NET_IPV4_PROTO_TCP
    add x2, x2, x20
    add x0, x19, #34
    mov x1, x20
    bl pi4_net_sum16_range
    mov x2, x0
.Lpi4_net_tcp_checksum_fold:
    lsr x3, x2, #16
    and x2, x2, #0xffff
    add x2, x2, x3
    lsr x3, x2, #16
    cbnz x3, .Lpi4_net_tcp_checksum_fold
    mvn x0, x2
    and x0, x0, #0xffff

    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret
.size pi4_net_tcp_checksum, . - pi4_net_tcp_checksum

.global pi4_net_prepare_status_sector
.type pi4_net_prepare_status_sector, %function
pi4_net_prepare_status_sector:
    stp x29, x30, [sp, #-48]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    str x21, [sp, #32]

    ldr x19, =pi4_net_status_sector
    mov x0, x19
    mov x1, #512
    bl pi4_net_zero_region

    ldr x0, =0x30545354454e4256
    str x0, [x19]
    mov x0, #1
    str x0, [x19, #8]
    ldr x0, =((PI4_NET_STATIC_IP0 << 24) | (PI4_NET_STATIC_IP1 << 16) | (PI4_NET_STATIC_IP2 << 8) | PI4_NET_STATIC_IP3)
    str x0, [x19, #16]
    ldr x0, =PI4_NET_MAC0_BE32
    str x0, [x19, #24]
    mov x0, #PI4_NET_MAC1_BE16
    str x0, [x19, #32]
    adr x0, pi4_net_status_phase
    ldr x0, [x0]
    str x0, [x19, #40]
    adr x0, pi4_net_status_write_result
    ldr x0, [x0]
    str x0, [x19, #48]
    adr x0, pi4_net_status_write_count
    ldr x0, [x0]
    str x0, [x19, #56]

    adr x0, pi4_net_status_probe
    ldr x0, [x0]
    cmp x0, #PI4_NET_PROBE_MMIO_OK
    b.lo .Lpi4_net_status_sector_copy_start
    cmp x0, #PI4_NET_PROBE_BAD
    b.eq .Lpi4_net_status_sector_copy_start
    bl pi4_net_capture_mac_counters

.Lpi4_net_status_sector_copy_start:
    adr x20, pi4_net_status_probe
    adr x21, pi4_net_status_values_end
    add x19, x19, #64
.Lpi4_net_status_sector_copy:
    cmp x20, x21
    b.hs .Lpi4_net_status_sector_done
    ldr x0, [x20], #8
    str x0, [x19], #8
    b .Lpi4_net_status_sector_copy

.Lpi4_net_status_sector_done:
    ldr x0, =pi4_net_status_sector
    ldr x21, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #48
    ret
.size pi4_net_prepare_status_sector, . - pi4_net_prepare_status_sector

.type pi4_net_capture_mac_counters, %function
pi4_net_capture_mac_counters:
    ldr x2, =PI4_NET_GENET_ARM_BASE
    ldr w0, [x2, #(PI4_GENET_UMAC_OFF + PI4_GENET_UMAC_MIB_TX_PKTS)]
    adr x1, pi4_net_status_tx_mib_packets
    str x0, [x1]
    ldr w0, [x2, #(PI4_GENET_UMAC_OFF + PI4_GENET_UMAC_MIB_RX_PKTS)]
    adr x1, pi4_net_status_rx_mib_packets
    str x0, [x1]
    ret
.size pi4_net_capture_mac_counters, . - pi4_net_capture_mac_counters

.type pi4_net_scan_genet_dtb, %function
pi4_net_scan_genet_dtb:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    adr x0, pi4_status_pi4dtb
    ldr w0, [x0]
    ldr w1, =VIBE_PI4_STATUS_PI4DTB_OK
    cmp w0, w1
    b.ne .Lpi4_net_scan_not_found

    adr x0, pi4_status_pi4dtb_root
    ldr x1, [x0]
    cbz x1, .Lpi4_net_scan_not_found
    adr x0, pi4_status_pi4dtb_struct_off
    ldr x9, [x0]
    adr x0, pi4_status_pi4dtb_struct_size
    ldr x10, [x0]
    add x11, x20, x9
    add x2, x11, x10
    adr x0, pi4_status_pi4dtb_strings_off
    ldr x9, [x0]
    adr x0, pi4_status_pi4dtb_strings_size
    ldr x10, [x0]
    add x3, x20, x9
    add x4, x3, x10
    add x5, x1, #8
    mov x6, xzr
    mov x7, xzr

.Lpi4_net_scan_loop:
    add x9, x5, #4
    cmp x9, x2
    b.hi .Lpi4_net_scan_not_found
    ldr w0, [x5]
    rev w0, w0
    add x5, x5, #4

    cmp w0, #PI4_FDT_BEGIN_NODE
    b.eq .Lpi4_net_scan_begin_node
    cmp w0, #PI4_FDT_END_NODE
    b.eq .Lpi4_net_scan_end_node
    cmp w0, #PI4_FDT_PROP
    b.eq .Lpi4_net_scan_prop
    cmp w0, #PI4_FDT_NOP
    b.eq .Lpi4_net_scan_loop
    cmp w0, #PI4_FDT_END
    b.eq .Lpi4_net_scan_not_found
    b .Lpi4_net_scan_not_found

.Lpi4_net_scan_begin_node:
    mov x6, xzr
    mov x7, xzr
    mov x10, x5
.Lpi4_net_scan_name_loop:
    cmp x10, x2
    b.hs .Lpi4_net_scan_not_found
    ldrb w11, [x10], #1
    cbnz w11, .Lpi4_net_scan_name_loop
    add x5, x10, #3
    bic x5, x5, #3
    cmp x5, x2
    b.hi .Lpi4_net_scan_not_found
    b .Lpi4_net_scan_loop

.Lpi4_net_scan_end_node:
    cbz x6, .Lpi4_net_scan_loop
    cbnz x7, .Lpi4_net_scan_reset_node
    b .Lpi4_net_scan_found

.Lpi4_net_scan_reset_node:
    mov x6, xzr
    mov x7, xzr
    b .Lpi4_net_scan_loop

.Lpi4_net_scan_prop:
    add x9, x5, #8
    cmp x9, x2
    b.hi .Lpi4_net_scan_not_found
    ldr w9, [x5]
    rev w9, w9
    ldr w10, [x5, #4]
    rev w10, w10
    add x11, x5, #8
    uxtw x12, w9
    add x12, x12, #3
    bic x12, x12, #3
    add x13, x11, x12
    cmp x13, x2
    b.hi .Lpi4_net_scan_not_found

    uxtw x14, w10
    add x14, x3, x14
    cmp x14, x4
    b.hs .Lpi4_net_scan_skip_prop
    adr x15, pi4_net_compatible_name
    bl pi4_net_string_equal
    cbnz x0, .Lpi4_net_scan_check_compatible
    uxtw x14, w10
    add x14, x3, x14
    adr x15, pi4_net_status_name
    bl pi4_net_string_equal
    cbnz x0, .Lpi4_net_scan_check_status
    b .Lpi4_net_scan_skip_prop

.Lpi4_net_scan_check_compatible:
    cmp w9, #22
    b.lo .Lpi4_net_scan_skip_prop
    mov x14, x11
    adr x15, pi4_net_genet_compatible
    bl pi4_net_string_equal
    cbz x0, .Lpi4_net_scan_skip_prop
    mov x6, #1
    b .Lpi4_net_scan_skip_prop

.Lpi4_net_scan_check_status:
    cmp w9, #8
    b.lo .Lpi4_net_scan_skip_prop
    mov x14, x11
    adr x15, pi4_net_disabled_status
    bl pi4_net_string_equal
    cbz x0, .Lpi4_net_scan_skip_prop
    mov x7, #1
    b .Lpi4_net_scan_skip_prop

.Lpi4_net_scan_skip_prop:
    mov x5, x13
    b .Lpi4_net_scan_loop

.Lpi4_net_scan_found:
    mov x0, #1
    b .Lpi4_net_scan_done

.Lpi4_net_scan_not_found:
    mov x0, xzr
    b .Lpi4_net_scan_done

.Lpi4_net_scan_done:
    ldp x29, x30, [sp], #16
    ret
.size pi4_net_scan_genet_dtb, . - pi4_net_scan_genet_dtb

.type pi4_net_string_equal, %function
pi4_net_string_equal:
    ldrb w0, [x14], #1
    ldrb w1, [x15], #1
    cmp w0, w1
    b.ne .Lpi4_net_string_no
    cbnz w0, pi4_net_string_equal
    mov x0, #1
    ret
.Lpi4_net_string_no:
    mov x0, xzr
    ret
.size pi4_net_string_equal, . - pi4_net_string_equal

.section .rodata.pi4_net, "a", %progbits
pi4_net_compatible_name:
    .asciz "compatible"
pi4_net_status_name:
    .asciz "status"
pi4_net_genet_compatible:
    .asciz "brcm,bcm2711-genet-v5"
pi4_net_disabled_status:
    .asciz "disabled"
pi4_net_ssh_banner:
    .ascii "SSH-2.0-vibe-os_pi4\r\n"
pi4_net_ssh_kexinit_packet:
    .byte 0x00, 0x00, 0x00, 0x9c
    .byte 0x0a
    .byte PI4_NET_SSH_MSG_KEXINIT
    .ascii "vibe-os-pi4-kex!"
    .byte 0x00, 0x00, 0x00, 0x11
    .ascii "curve25519-sha256"
    .byte 0x00, 0x00, 0x00, 0x0c
    .ascii "rsa-sha2-256"
    .byte 0x00, 0x00, 0x00, 0x0a
    .ascii "aes128-ctr"
    .byte 0x00, 0x00, 0x00, 0x0a
    .ascii "aes128-ctr"
    .byte 0x00, 0x00, 0x00, 0x0d
    .ascii "hmac-sha2-256"
    .byte 0x00, 0x00, 0x00, 0x0d
    .ascii "hmac-sha2-256"
    .byte 0x00, 0x00, 0x00, 0x04
    .ascii "none"
    .byte 0x00, 0x00, 0x00, 0x04
    .ascii "none"
    .byte 0x00, 0x00, 0x00, 0x00
    .byte 0x00, 0x00, 0x00, 0x00
    .byte 0x00
    .byte 0x00, 0x00, 0x00, 0x00
    .byte 0x76, 0x69, 0x62, 0x65, 0x2d, 0x6f, 0x73, 0x2d, 0x70, 0x69
pi4_net_udp_probe_payload:
    .ascii "vibe-os_pi4_udp_probe\n"

.balign 512
.macro PI4_NET_STATIC_STATUS_SECTOR phase, pattern
    .quad 0x3054454e49503456
    .quad 2
    .quad \phase
    .quad \pattern
    .rept 60
    .quad \pattern
    .endr
.endm

.global pi4_net_static_sector_storage_probed
pi4_net_static_sector_storage_probed:
    PI4_NET_STATIC_STATUS_SECTOR 0x1101, 0x1111111111111101

.global pi4_net_static_sector_net_run_done
pi4_net_static_sector_net_run_done:
    PI4_NET_STATIC_STATUS_SECTOR 0x1202, 0x2222222222221202

.global pi4_net_static_sector_storage_handoff_done
pi4_net_static_sector_storage_handoff_done:
    PI4_NET_STATIC_STATUS_SECTOR 0x1300, 0x3333333333331300

.section .pi4_net_status, "aw", %progbits
.balign 8
.global pi4_net_status_values_start
.global pi4_net_status_values_end
.global pi4_net_status_phase
.global pi4_net_status_write_result
.global pi4_net_status_write_count
.global pi4_net_status_probe
.global pi4_net_status_bus_base
.global pi4_net_status_arm_base
.global pi4_net_status_span
.global pi4_net_status_sys_rev
.global pi4_net_status_port_ctrl
.global pi4_net_status_rgmii_oob
.global pi4_net_status_umac_cmd
.global pi4_net_status_umac_cmd_before
.global pi4_net_status_umac_cmd_reset
.global pi4_net_status_umac_cmd_write
.global pi4_net_status_umac_cmd_after
.global pi4_net_status_sys_rbuf_flush
.global pi4_net_status_rdma_ctrl
.global pi4_net_status_rdma_status
.global pi4_net_status_tdma_ctrl
.global pi4_net_status_tdma_status
.global pi4_net_status_tx_cons_hw
.global pi4_net_status_tx_read_ptr_hw
.global pi4_net_status_tx_write_ptr_hw
.global pi4_net_status_tx_desc_status_hw
.global pi4_net_status_rbuf_ctrl
.global pi4_net_status_rbuf_chk
.global pi4_net_status_mdio_cmd
.global pi4_net_status_phy_addr
.global pi4_net_status_phy_bmsr
.global pi4_net_status_phy_id1
.global pi4_net_status_phy_id2
.global pi4_net_status_link
.global pi4_net_status_result
.global pi4_net_status_poll_deadline
.global pi4_net_status_rx_prod
.global pi4_net_status_rx_cons
.global pi4_net_status_rx_length_status
.global pi4_net_status_rx_packets
.global pi4_net_status_tx_prod
.global pi4_net_status_tx_length_status
.global pi4_net_status_tx_packets
.global pi4_net_status_tx_mib_packets
.global pi4_net_status_rx_mib_packets
.global pi4_net_status_hfb_ctrl
.global pi4_net_status_arp_last_op
.global pi4_net_status_arp_replies
.global pi4_net_status_icmp_replies
.global pi4_net_status_gratuitous_arps
.global pi4_net_status_tcp_last_flags
.global pi4_net_status_tcp_src_port
.global pi4_net_status_tcp_dst_port
.global pi4_net_status_tcp_last_seq
.global pi4_net_status_tcp_last_ack
.global pi4_net_status_tcp_checksum
.global pi4_net_status_tcp_syns
.global pi4_net_status_tcp_synacks
.global pi4_net_status_tcp_banners
.global pi4_net_status_udp_probes
pi4_net_status_values_start:
pi4_net_status_phase:
    .quad 0
pi4_net_status_write_result:
    .quad 0
pi4_net_status_write_count:
    .quad 0
pi4_net_status_probe:
    .quad PI4_NET_PROBE_WAIT
pi4_net_status_bus_base:
    .quad 0
pi4_net_status_arm_base:
    .quad 0
pi4_net_status_span:
    .quad 0
pi4_net_status_sys_rev:
    .quad 0
pi4_net_status_port_ctrl:
    .quad 0
pi4_net_status_rgmii_oob:
    .quad 0
pi4_net_status_umac_cmd:
    .quad 0
pi4_net_status_umac_cmd_before:
    .quad 0
pi4_net_status_umac_cmd_reset:
    .quad 0
pi4_net_status_umac_cmd_write:
    .quad 0
pi4_net_status_umac_cmd_after:
    .quad 0
pi4_net_status_sys_rbuf_flush:
    .quad 0
pi4_net_status_rdma_ctrl:
    .quad 0
pi4_net_status_rdma_status:
    .quad 0
pi4_net_status_tdma_ctrl:
    .quad 0
pi4_net_status_tdma_status:
    .quad 0
pi4_net_status_tx_cons_hw:
    .quad 0
pi4_net_status_tx_read_ptr_hw:
    .quad 0
pi4_net_status_tx_write_ptr_hw:
    .quad 0
pi4_net_status_tx_desc_status_hw:
    .quad 0
pi4_net_status_rbuf_ctrl:
    .quad 0
pi4_net_status_rbuf_chk:
    .quad 0
pi4_net_status_mdio_cmd:
    .quad 0
pi4_net_status_phy_addr:
    .quad 0
pi4_net_status_phy_bmsr:
    .quad 0
pi4_net_status_phy_id1:
    .quad 0
pi4_net_status_phy_id2:
    .quad 0
pi4_net_status_link:
    .quad 0
pi4_net_status_result:
    .quad 0
pi4_net_status_poll_deadline:
    .quad 0
pi4_net_status_rx_prod:
    .quad 0
pi4_net_status_rx_cons:
    .quad 0
pi4_net_status_rx_length_status:
    .quad 0
pi4_net_status_rx_packets:
    .quad 0
pi4_net_status_tx_prod:
    .quad 0
pi4_net_status_tx_length_status:
    .quad 0
pi4_net_status_tx_packets:
    .quad 0
pi4_net_status_tx_mib_packets:
    .quad 0
pi4_net_status_rx_mib_packets:
    .quad 0
pi4_net_status_hfb_ctrl:
    .quad 0
pi4_net_status_arp_last_op:
    .quad 0
pi4_net_status_arp_replies:
    .quad 0
pi4_net_status_icmp_replies:
    .quad 0
pi4_net_status_gratuitous_arps:
    .quad 0
pi4_net_status_tcp_last_flags:
    .quad 0
pi4_net_status_tcp_src_port:
    .quad 0
pi4_net_status_tcp_dst_port:
    .quad 0
pi4_net_status_tcp_last_seq:
    .quad 0
pi4_net_status_tcp_last_ack:
    .quad 0
pi4_net_status_tcp_checksum:
    .quad 0
pi4_net_status_tcp_syns:
    .quad 0
pi4_net_status_tcp_synacks:
    .quad 0
pi4_net_status_tcp_banners:
    .quad 0
pi4_net_status_udp_probes:
    .quad 0
pi4_net_status_values_end:

.section .bss.pi4_net, "aw", %nobits
.balign 64
pi4_net_rx_buffers:
    .skip PI4_NET_RX_RING_SIZE * PI4_NET_RX_BUF_BYTES
.balign 64
pi4_net_tx_buffers:
    .skip PI4_NET_TX_RING_SIZE * PI4_NET_TX_BUF_BYTES
.balign 64
pi4_net_status_sector:
    .skip 512

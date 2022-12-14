---
meta:
  id: iss
doc: |
  :field dest_callsign: ax25_frame.ax25_header.dest_callsign_raw.callsign_ror.callsign
  :field dest_ssid: ax25_frame.ax25_header.dest_ssid_raw.ssid
  :field src_callsign: ax25_frame.ax25_header.src_callsign_raw.callsign_ror.callsign
  :field src_ssid: ax25_frame.ax25_header.src_ssid_raw.ssid
  :field ctl: ax25_frame.ax25_header.ctl
  :field pid: ax25_frame.payload.pid
  :field data_type: ax25_frame.payload.info.data_type
  :field longitude: ax25_frame.payload.info.longitude
  :field speed_and_course: ax25_frame.payload.info.speed_and_course
  :field symbol_code: ax25_frame.payload.info.symbol_code
  :field sym_table_id: ax25_frame.payload.info.sym_table_id
  :field tlm_flag: ax25_frame.payload.info.tlm_flag
  :field status_message: ax25_frame.payload.info.tlm_data.status_message
  :field mode: ax25_frame.payload.info.tlm_data.mode
  :field temp: ax25_frame.payload.info.temp
  :field aprs_message: ax25_frame.payload.info.aprs_message

  Attention: `rpt_callsign` cannot be accessed because `rpt_instance` is an
  array of unknown size at the beginning of the parsing process! Left an
  example in here.

seq:
  - id: ax25_frame
    type: ax25_frame
    doc-ref: 'https://www.tapr.org/pub_ax25.html'
types:
  ax25_frame:
    seq:
      - id: ax25_header
        type: ax25_header
      - id: payload
        type:
          switch-on: ax25_header.ctl & 0x13
          cases:
            0x03: ui_frame
            0x13: ui_frame
            0x00: i_frame
            0x02: i_frame
            0x10: i_frame
            0x12: i_frame
            # 0x11: s_frame
  ax25_header:
    seq:
      - id: dest_callsign_raw
        type: callsign_raw
      - id: dest_ssid_raw
        type: ssid_mask
      - id: src_callsign_raw
        type: callsign_raw
      - id: src_ssid_raw
        type: ssid_mask
      - id: repeater
        type: repeater
        if: (src_ssid_raw.ssid_mask & 0x01) == 0
        doc: 'Repeater flag is set!'
      - id: ctl
        type: u1
  repeater:
    seq:
      - id: rpt_instance
        type: repeaters
        repeat: until
        repeat-until: ((_.rpt_ssid_raw.ssid_mask & 0x1) == 0x1)
        doc: 'Repeat until no repeater flag is set!'
  repeaters:
    seq:
      - id: rpt_callsign_raw
        type: callsign_raw
      - id: rpt_ssid_raw
        type: ssid_mask
  callsign_raw:
    seq:
      - id: callsign_ror
        process: ror(1)
        size: 6
        type: callsign
  callsign:
    seq:
      - id: callsign
        type: str
        encoding: ASCII
        size: 6
  ssid_mask:
    seq:
      - id: ssid_mask
        type: u1
    instances:
      ssid:
        value: (ssid_mask & 0x0f) >> 1
  i_frame:
    seq:
      - id: pid
        type: u1
      - id: ax25_info
        size-eos: true
  ui_frame:
    seq:
      - id: pid
        type: u1
      - id: info
        type:
          switch-on: '_parent.ax25_header.src_callsign_raw.callsign_ror.callsign'
          cases:
            '"NA1SS "': aprs_mic_e_t
            _: aprs_t
        size-eos: true
  aprs_mic_e_t:
    seq:
      - id: data_type
        type: str
        size: 1
        encoding: ASCII
      - id: longitude
        type: str
        size: 3
        encoding: ASCII
      - id: speed_and_course
        type: str
        size: 3
        encoding: ASCII
      - id: symbol_code
        type: str
        size: 1
        encoding: ASCII
      - id: sym_table_id
        type: str
        size: 1
        encoding: ASCII
      - id: tlm_flag
        type: str
        size: 1
        encoding: ASCII
      - id: tlm_data
        type:
          switch-on: tlm_flag
          cases:
            '"]"': kenwood_tmd700_t
        size-eos: true
        doc: |
          The APRS messages sent by the Kenwood TM-D710 are encoded
          in the MIC-E format.
          Additional comments:
          "The 9k6 packet is being generated by the Kenwood. It???s the
          standard Mic-E format APRS beacon that the radio generates. It
          carries info that is displayed on a receiving Kenwood radio,
          such as location, course, and speed. The radio is not receiving
          GPS data, so most of that ???data??? has no meaning for ISS.
          The only things of interest for ARISS are the current program
          mode (indicated by the status message) and the temperature of
          the radio final amp.
          You can see the temperature as the final 2 characters of the
          dest address, 0P0PS4 in the packet you quoted. It???s a bit odd,
          because of the Mic-E encoding. In Mic-E, P-Y decodes as 0-9,
          so S4 represents 34 degrees C"
          all you get out of it is a single temperature i think
          Note: 'A' to 'K' is not used in bytes 4..6
    instances:
      mic_e_callsign:
        io: _root._io
        pos: 0x00
        type: u1
        repeat: expr
        repeat-expr: 6
      temp:
        value: >-
          (((mic_e_callsign[4] >> 1) - 80) * 10)
          + ((mic_e_callsign[5] >> 1) - 48)
      aprs_message:
        pos: 0x0
        type: str
        encoding: ASCII
        size-eos: true
  kenwood_tmd700_t:
    seq:
      - id: status_message
        type: str
        size-eos: true
        encoding: ASCII
    instances:
      mode:
        pos: 0x0a
        type: str
        size: 3
        encoding: ASCII
  aprs_t:
    seq:
      - id: aprs_message
        type: str
        encoding: ASCII
        size-eos: true

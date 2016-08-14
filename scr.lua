
do
    local mstr_proto = Proto("MSTR", "Cisco Multistream - P2P Call")
    
    local  mstr_app_fb_id = ProtoField.string("mstr.appid", "Application Feedback Identifier", base.NONE)
    local mstr_type = ProtoField.uint16( "mstr.type","Message Type",  base.DEC ,nil, 0xFFF0)
    local mstr_ver = ProtoField.uint16( "mstr.ver", "Version",   base.DEC,  nil,0x000F)
    local mstr_seq = ProtoField.uint16("mstr.seq", "Sequence Number", base.DEC, nil)
    mstr_proto.fields = { mstr_app_fb_id, mstr_type, mstr_ver, mstr_seq,     }


    ---- SCR Header
    local scr_proto = Proto("SCR", "Sub-session Channel Request")
    local scr_vid = ProtoField.uint8( "scr.vid","Subsession Channel Id",  base.DEC ,nil)
    local scr_sid = ProtoField.uint8( "scr.sid","Source Id",  base.DEC ,nil)
    local scr_len = ProtoField.uint16( "scr.len","Length",  base.DEC ,nil)
    local scr_br = ProtoField.uint32( "scr.br","Bitrate",  base.DEC ,nil)
    scr_proto.fields = { scr_vid, scr_sid, scr_len, scr_br, }

    --- SCR Policy Info
    local scr_policy_proto = Proto("scr_Policy", "Policy Info")
    local scr_policy = ProtoField.uint16( "scr.policy","Policy Id",  base.DEC ,nil)
    local scr_po_len = ProtoField.uint16( "scr.polen","Policy Info Length",  base.DEC ,nil)
    local scr_po_pri = ProtoField.uint8( "scr.popri","Priority",  base.DEC ,nil)
    local scr_po_gro = ProtoField.uint8( "scr.pogroid","Groupint Id",  base.DEC ,nil)
    local scr_po_rev = ProtoField.uint16( "scr.porev","Reserved",  base.DEC ,nil)
    scr_policy_proto.fields = {  scr_policy, scr_po_len, scr_po_pri, scr_po_gro, scr_po_rev, }

    --- SCR Payload Info
    local scr_pt_proto = Proto("scr_pt", "Palyad Infomation")
    local scr_pt_type = ProtoField.uint8( "scr.pttype","Payload Type",  base.DEC ,nil)
    local scr_pt_rev = ProtoField.uint8( "scr.ptrev","Reserved",  base.DEC ,nil)
    local scr_pt_len = ProtoField.uint16( "scr.ptlen","Length",  base.DEC ,nil)
    local scr_pt_mbps = ProtoField.uint32( "scr.ptmbps","MaxMbps",  base.DEC ,nil)
    local scr_pt_fs = ProtoField.uint16( "scr.ptfs","MaxFs",  base.DEC ,nil)
    local scr_pt_fps = ProtoField.uint16( "scr.ptfps","MaxFps",  base.DEC ,nil)
    local scr_pt_fps = ProtoField.uint16( "scr.ptfps","MaxFps",  base.DEC ,nil)
--    local scr_pt_mmfs = ProtoField.uint16( "scr.ptlen","Length",  base.DEC ,nil)
    scr_pt_proto.fields = { scr_pt_type, scr_pt_rev, scr_pt_len, scr_pt_mbps, scr_pt_fs, scr_pt_fps, }


    --- SCA 
    local sca_proto = Proto("SCA", "Sub-session Channel Announce")
    local sca_scr_req = ProtoField.uint16("sca.scrreq", "Current Request", base.DEC, nil)
    local sca_subavai = ProtoField.uint8("sca.subavai", "Sub-session Available", base.DEC, nil)
    local sca_adj = ProtoField.uint8("sca.adj", "Max Adj.", base.DEC, nil, 0xF0)
    local sca_rev = ProtoField.uint8("sca.rev", "Reserved", base.DEC, nil, 0x0E)
    local sca_ack = ProtoField.uint8("sca.rev", "ACK Required", base.DEC, nil, 0x01)
    sca_proto.fields = { sca_scr_req, sca_subavai, sca_adj, sca_rev, sca_ack, }
     
    function mstr_proto.dissector(tvb, pinfo, treeitem)
        
        pinfo.cols.info:set("Multistream")

        local offset = 0
        local tvb_len = tvb:len()
        
        local mstr_tree = treeitem:add(mstr_proto, tvb:range(offset))
        
        local msg_type = tvb:range(4,2):bitfield(0, 12)
        local msg_seq = tvb:range(6,2):uint()

        --  Multistream Header
        mstr_tree:add(mstr_app_fb_id, tvb:range(offset, 4));  offset = offset + 4;        
        mstr_tree:add(mstr_type, tvb:range(offset,2))
        mstr_tree:add(mstr_ver, tvb:range(offset, 2));        offset = offset + 2;
        mstr_tree:add(mstr_seq, tvb:range(offset, 2));        offset = offset + 2;

        if msg_type == 1 then
            pinfo.cols.protocol:set("SCR")
            pinfo.cols.info:append(" - SCR Seq: ".. msg_seq .."")

            --- SCR
            local scr_tree = mstr_tree:add("Sub-sesseion Channel Request", tvb:range(offset))

            local virtual_id = tvb:range(offset, 1):uint();
            pinfo.cols.info:append(" vid: ".. virtual_id .. " ")
            scr_tree:add(scr_vid, tvb:range(offset, 1));        offset = offset + 1;
            scr_tree:add(scr_sid, tvb:range(offset, 1));        offset = offset + 1;
            scr_tree:add(scr_len, tvb:range(offset, 2));        offset = offset + 2;
            scr_tree:add(scr_br, tvb:range(offset, 4));        offset = offset + 4;

            local scr_policy_tree = scr_tree:add("Policy Infomation")
            scr_policy_tree:add(scr_policy, tvb:range(offset, 2));        offset = offset + 2;
            local policy_length = tvb:range(offset,2):uint()
            if policy_length > 0 then
                scr_policy_tree:add(scr_po_len, tvb:range(offset, 2));        offset = offset + 2;
                scr_policy_tree:add(scr_po_pri, tvb:range(offset, 1));        offset = offset + 1;
                scr_policy_tree:add(scr_po_gro, tvb:range(offset, 1));        offset = offset + 1;
                scr_policy_tree:add(scr_po_rev, tvb:range(offset, 2));        offset = offset + 2;
            end
                

            local scr_pt_tree = scr_tree:add("Payload Information")
            local payload_type = tvb:range(offset, 1):uint()
            pinfo.cols.info:append(" PT: ".. payload_type .. " ")
            scr_pt_tree:add(scr_pt_type, tvb:range(offset, 1));        offset = offset + 1;
            scr_pt_tree:add(scr_pt_rev, tvb:range(offset, 1));        offset = offset + 1;
            local payload_lenght = tvb:range(offset,2):uint()
            if payload_lenght > 0 then
                scr_pt_tree:add(scr_pt_len, tvb:range(offset, 2));        offset = offset + 2;
                scr_pt_tree:add(scr_pt_mbps, tvb:range(offset, 4));        offset = offset + 4;
                scr_pt_tree:add(scr_pt_fs, tvb:range(offset, 2));        offset = offset + 2;
                scr_pt_tree:add(scr_pt_fps, tvb:range(offset, 2));        offset = offset + 2;
        --        scr_pt_tree:add(scr_pt_type, tvb:range(offset, 1));        offset = offset + 1;
            end
    --
        elseif msg_type == 2 then
            pinfo.cols.protocol:set("SCA")
            local scr_seq = tvb:range(offset, 2):uint()
            pinfo.cols.info:append(" - SCA Seq: ".. msg_seq .." scr Seq: " .. scr_seq .."")

            --- SCA
            local sca_tree = mstr_tree:add("Sub-session Channel Announce")
            sca_tree:add(sca_scr_req, tvb:range(offset, 2));        offset = offset + 2;
            sca_tree:add(sca_subavai, tvb:range(offset, 1));        offset = offset + 1;
            sca_tree:add(sca_adj, tvb:range(offset, 1));        
            sca_tree:add(sca_rev, tvb:range(offset, 1));       
            local ack_required = tvb:range(offset, 1):bitfield(7,1)
            pinfo.cols.info:append(" ACK Required: ".. ack_required .. "")
            sca_tree:add(sca_ack, tvb:range(offset, 1));        offset = offset + 1;

        elseif mst_type == 3 then
            pinfo.cols.protocol:set("SCAACK")

        end

    end
    local tcp_port_table = DissectorTable.get("rtcp.psfb.fmt")
    tcp_port_table:add(15, mstr_proto)
end

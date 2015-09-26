package Test::Siebel::Srvrmgr::ListParser::Output::Tabular::ListProcs;

use Test::Moose;
use Test::Most;
use parent qw(Test::Siebel::Srvrmgr::ListParser::Output::Tabular);

sub set_timezone : Test(startup) {

    $ENV{SIEBEL_TZ} = 'America/Sao_Paulo';

}

sub unset_timezone : Test(shutdown) {

    delete $ENV{IEBEL_TZ};

}

sub get_data_type {

    return 'list_procs';

}

sub get_cmd_line {

    return 'list procs';

}

sub class_methods : Tests(no_plan) {

    my $test = shift;

    my $server = 'foobar_00023';

    does_ok( $test->get_output(),
        'Siebel::Srvrmgr::ListParser::Output::Tabular::ByServer' );

    $test->SUPER::class_methods( [qw(get_procs)] );

    my @del_attribs = (
        'server',       'comp_alias', 'pid',          'sisproc',
        'normal_tasks', 'sub_tasks',  'hidden_tasks', 'vm_free',
        'vm_used',      'pm_used',    'proc_enabled', 'run_state',
        'sockets'
    );

    BAIL_OUT("Couldn't parse the output, aborting the test")
      unless ( ( exists( $test->get_output()->get_data_parsed()->{$server} ) )
        and
        ( ref( $test->get_output()->get_data_parsed()->{$server} ) eq 'ARRAY' )
      );

    $test->num_tests(
        '+'
          . (
            (
                scalar(
                    @{ $test->get_output()->get_data_parsed()->{$server} }
                ) * ( scalar(@del_attribs) + 1 )
            ) + 13
          )
    );

    ok( $test->get_output()->get_data_parsed(), 'get_data_parsed works' );

    my $expected = $test->get_expected_del();

    cmp_deeply( $test->get_output()->get_data_parsed(),
        $expected, 'get_data_parsed() returns the correct data structure' );

# :WORKAROUND:09/26/2015 12:54:42 AM:: cmp_deeply doesn't work correctly when receives list or arrays
    my @servers  = $test->get_output()->get_servers();
    my @expected = ( sort(qw(foobar_0005 foobar_00023 foobar_00022)) );
    cmp_deeply( \@servers, \@expected,
        'get_servers() returns the expected value' );

    dies_ok { $test->get_output()->get_procs() }
    'get_procs dies when invoked without a Siebel server name';
    like(
        $@,
        qr/Siebel\sServer\sname\sparameter\sis\srequired\sand\smust\sbe\svalid/,
        'dies with correct message'
    );
    dies_ok { $test->get_output()->get_procs('') }
    'get_procs dies when invoked with an invalid Siebel server name';
    like(
        $@,
        qr/Siebel\sServer\sname\sparameter\sis\srequired\sand\smust\sbe\svalid/,
        'dies with correct message'
    );

    dies_ok { $test->get_output()->get_procs('foobar') }
    'get_procs dies when invoked with an unexisting Siebel server name';
    like(
        $@,
        qr/\sis\snot\savailable\sin\sthe\soutput\sparsed/,
        'dies with correct message'
    );

    my $next_task = $test->get_output()->get_procs($server);

    is( ref($next_task), 'CODE', 'get_tasks returns a code reference' );

    while ( my $task = $next_task->() ) {

        isa_ok( $task, 'Siebel::Srvrmgr::ListParser::Output::ListProcs::Proc' );

        foreach my $attrib (@del_attribs) {

            has_attribute_ok( $task, $attrib );

        }

    }

    ok(
        $test->get_output()->set_data_parsed(
            {
                'my_server' => [
                    Siebel::Srvrmgr::ListParser::Output::ListProcs::Proc->new(
                        {
                            server       => 'my_server',
                            pid          => '5364',
                            comp_alias   => 'WfProcMgr',
                            sisproc      => 1,
                            normal_tasks => 1,
                            sub_tasks    => 0,
                            hidden_tasks => 1,
                            vm_free      => 1012995,
                            vm_used      => 35580,
                            pm_used      => 37688,
                            proc_enabled => 1,
                            sockets      => 0,
                            run_state    => 'Running',
                        }
                    )
                ]
            }
        ),
        'set_data_parsed works with correct parameters'
    );

    dies_ok { $test->get_output()->set_data_parsed('foobar') }
    'set_data_parsed dies with incorrect parameters';

}

sub get_expected_del {

    return {
        'foobar_0005' => [
            [
                'foobar_0005', 'SRProc', '3068', '5',
                '2',           '0',      '6',    '1012995',
                '35580',       '37688',  'True', 'Running',
                '0'
            ],
            [
                'foobar_0005', 'SRBroker', '1756', '4',
                '9',           '0',        '6',    '1035927',
                '12648',       '14784',    'True', 'Running',
                '0'
            ],
            [
                'foobar_0005', 'ServerMgr', '11948', '714',
                '1',           '0',         '2',     '1037723',
                '10852',       '12788',     'True',  'Running',
                '0'
            ],
            [
                'foobar_0005', 'DocServer', '5828', '8',
                '0',           '0',         '7',    '1006936',
                '41639',       '53869',     'True', 'Running',
                '0'
            ],
            [
                'foobar_0005', 'SiebSrvr', '5928', '1',
                '2',           '0',        '2',    '1046796',
                '1779',        '3484',     'True', 'Running',
                '0'
            ],
            [
                'foobar_0005', 'SCBroker', '3648', '3',
                '1',           '0',        '2',    '1047332',
                '1243',        '2235',     'True', 'Running',
                '0'
            ],
            [
                'foobar_0005', 'SCBroker', '6044', '2',
                '1',           '0',        '2',    '1047332',
                '1243',        '2235',     'True', 'Running',
                '0'
            ],
            [
                'foobar_0005', 'SvrTaskPersist', '3608', '7', '1', '0', '3',
                '1006306', '42269', '54344', 'True', 'Running', '0'
            ],
            [
                'foobar_0005', 'ServerMgr', '14076', '702',
                '1',           '0',         '2',     '1037679',
                '10896',       '12864',     'True',  'Running',
                '0'
            ],
            [
                'foobar_0005', 'AdminNotify', '6112', '6', '0', '0', '17',
                '1046651', '1924', '3041', 'True', 'Running', '0'
            ]
        ],
        'foobar_00023' => [
            [
                'foobar_00023', 'CommInboundRcvr', '5504', '29', '0', '0', '35',
                '947650', '100925', '40205', 'True', 'Running', '0'
            ],
            [
                'foobar_00023', 'EAIObjMgr_esn', '5394', '24', '0', '0', '10',
                '913870', '134705', '75087', 'True', 'Running', '0'
            ],
            [
                'foobar_00023', 'EAIObjMgr_esn', '5371', '23', '0', '0', '9',
                '916438', '132137', '73101', 'True', 'Running', '0'
            ],
            [
                'foobar_00023', 'EAIObjMgr_esn', '5353', '22', '0', '0', '11',
                '898040', '150535', '93470', 'True', 'Running', '0'
            ],
            [
                'foobar_00023', 'eCommunicationsObjMgr_esn',
                '5558',         '34',
                '0',            '0',
                '7',            '731661',
                '316914',       '201540',
                'True',         'Running',
                '0'
            ],
            [
                'foobar_00023', 'ServerMgr', '9075', '137', '1', '0', '2',
                '1020802', '27773', '7148', 'True', 'Running', '0'
            ],
            [
                'foobar_00023', 'WorkMonDish', '5176', '9', '1', '0', '3',
                '991059', '57516', '34774', 'True', 'Running', '0'
            ],
            [
                'foobar_00023', 'eCommunicationsObjMgr_esn',
                '5702',         '39',
                '0',            '0',
                '9',            '711624',
                '336951',       '220295',
                'True',         'Running',
                '0'
            ],
            [
                'foobar_00023', 'SiebSrvr', '5024', '1', '2', '0', '2',
                '1039160', '9415', '6633', 'True', 'Running', '0'
            ],
            [
                'foobar_00023', 'ServerMgr', '30989', '134', '1', '0', '2',
                '1020837', '27738', '6825', 'True', 'Running', '0'
            ],
            [
                'foobar_00023', 'ServerMgr', '534', '129', '1', '0', '2',
                '1020804', '27771', '7753', 'True', 'Running', '0'
            ],
            [
                'foobar_00023', 'WorkMonSWI', '5201', '12', '1', '0', '3',
                '986996', '61579', '38441', 'True', 'Running', '0'
            ],
            [
                'foobar_00023', 'WorMonOracle', '29612', '49', '1', '0', '3',
                '990958', '57617', '34775', 'True', 'Running', '0'
            ],
            [
                'foobar_00023', 'eCommunicationsObjMgr_esn',
                '5571',         '32',
                '1',            '0',
                '13',           '531854',
                '516721',       '398322',
                'True',         'Running',
                '0'
            ],
            [
                'foobar_00023', 'WfRecvMgr', '5184', '13', '0', '0', '26',
                '954054', '94521', '38468', 'True', 'Running', '0'
            ],
            [
                'foobar_00023', 'ServerMgr', '4979', '135', '1', '0', '2',
                '1020667', '27908', '7531', 'True', 'Running', '0'
            ],
            [
                'foobar_00023', 'WfProcMgr', '5203', '15',
                '0',            '0',         '27',   '880012',
                '168563',       '107793',    'True', 'Running',
                '0'
            ],
            [
                'foobar_00023', 'AdminNotify', '5094', '7', '0', '0', '17',
                '1035909', '12666', '2607', 'True', 'Running', '0'
            ],
            [
                'foobar_00023', 'ServerMgr', '5132', '136', '1', '0', '2',
                '1020837', '27738', '7522', 'True', 'Running', '0'
            ],
            [
                'foobar_00023', 'SvrTaskPersist', '5056', '8', '1', '0', '3',
                '961268', '87307', '41097', 'True', 'Running', '0'
            ],
            [
                'foobar_00023', 'SRProc', '5093', '6',
                '2',            '0',      '6',    '995037',
                '53538',        '30798',  'True', 'Running',
                '0'
            ],
            [
                'foobar_00023', 'CommConfigMgr', '5487', '28', '0', '0', '26',
                '954182', '94393', '38165', 'True', 'Running', '0'
            ],
            [
                'foobar_00023', 'eSalesObjMgr_esn', '5433', '25', '0', '0', '7',
                '1018825', '29750', '6389', 'True', 'Running', '0'
            ],
            [
                'foobar_00023', 'EAIObjMgr_esn', '5313', '20', '0', '0', '11',
                '861079', '187496', '130323', 'True', 'Running', '0'
            ],
            [
                'foobar_00023', 'eSalesCMEObjMgr_esn', '5724', '40', '0', '0',
                '7', '1018834', '29741', '6451', 'True', 'Running', '0'
            ],
            [
                'foobar_00023', 'SCBroker', '5048', '4', '1', '0', '2',
                '1039526', '9049', '2375', 'True', 'Running', '0'
            ],
            [
                'foobar_00023', 'SRBroker', '5039', '2',
                '43',           '0',        '10',   '1007397',
                '41178',        '9139',     'True', 'Running',
                '0'
            ],
            [
                'foobar_00023', 'EAIObjMgr_esn', '5291', '19', '0', '0', '11',
                '896661', '151914', '92069', 'True', 'Running', '0'
            ],
            [
                'foobar_00023', 'SCCObjMgr_esn', '5227', '16', '0', '0', '7',
                '1018808', '29767', '6381', 'True', 'Running', '0'
            ],
            [
                'foobar_00023', 'WfProcBatchMgr', '5162', '11', '0', '0', '26',
                '954304', '94271', '38448', 'True', 'Running', '0'
            ],
            [
                'foobar_00023', 'eCommunicationsObjMgr_esn',
                '5656',         '38',
                '1',            '0',
                '10',           '714122',
                '334453',       '217861',
                'True',         'Running',
                '0'
            ],
            [
                'foobar_00023', 'CommInboundProcessor', '5530', '30', '0', '0',
                '56', '947578', '100997', '37553', 'True', 'Running', '0'
            ],
            [
                'foobar_00023', 'SCBroker', '5040', '3', '1', '0', '2',
                '1039423', '9152', '2376', 'True', 'Running', '0'
            ],
            [
                'foobar_00023', 'ServerMgr', '7735', '45', '1', '0', '2',
                '1020002', '28573', '8146', 'True', 'Running', '0'
            ],
            [
                'foobar_00023', 'FSMSrvr', '5053', '5',
                '0',            '0',       '26',   '1033215',
                '15360',        '4750',    'True', 'Running',
                '0'
            ],
            [
                'foobar_00023', 'CommOutboundMgr', '5516', '31', '0', '0', '56',
                '943817', '104758', '38734', 'True', 'Running', '0'
            ],
            [
                'foobar_00023', 'AsgnSrvr', '5224', '14',
                '0',            '0',        '26',   '964218',
                '84357',        '57768',    'True', 'Running',
                '0'
            ],
            [
                'foobar_00023', 'eCommunicationsObjMgr_esn',
                '5670',         '37',
                '1',            '0',
                '10',           '689317',
                '359258',       '242956',
                'True',         'Running',
                '0'
            ],
            [
                'foobar_00023', 'eCommunicationsObjMgr_esn',
                '16116',        '61',
                '1',            '0',
                '12',           '744815',
                '303760',       '194297',
                'True',         'Running',
                '0'
            ],
            [
                'foobar_00023', 'eCommunicationsObjMgr_esn',
                '5619',         '35',
                '2',            '0',
                '11',           '691164',
                '357411',       '240082',
                'True',         'Running',
                '0'
            ],
            [
                'foobar_00023', 'eProdCfgObjMgr_esn', '5462', '27', '0', '0',
                '8', '957354', '91221', '38499', 'True', 'Running', '0'
            ],
            [
                'foobar_00023', 'XMLPReportServer', '5245', '18', '0', '0',
                '26', '956796', '91779', '37351', 'True', 'Running', '0'
            ],
            [
                'foobar_00023', 'ServerMgr', '28828', '127', '1', '0', '2',
                '1020547', '28028', '7806', 'True', 'Running', '0'
            ],
            [
                'foobar_00023', 'eCustomerObjMgr_esn', '5446', '26', '0', '0',
                '7', '1018852', '29723', '6423', 'True', 'Running', '0'
            ],
            [
                'foobar_00023', 'eChannelObjMgr_esn', '5256', '17', '0', '0',
                '7', '1018732', '29843', '6356', 'True', 'Running', '0'
            ],
            [
                'foobar_00023', 'EAIObjMgr_esn', '5332', '21', '0', '0', '11',
                '899830', '148745', '92243', 'True', 'Running', '0'
            ],
            [
                'foobar_00023', 'eCommunicationsObjMgr_esn',
                '5640',         '36',
                '1',            '0',
                '10',           '737042',
                '311533',       '193507',
                'True',         'Running',
                '0'
            ]
        ],
        'foobar_00022' => [
            [
                'foobar_00022', 'eCommunicationsObjMgr_esn',
                '17319',        '37',
                '0',            '0',
                '7',            '1018323',
                '30252',        '6474',
                'True',         'Running',
                '0'
            ],
            [
                'foobar_00022', 'ServerMgr', '27220', '86', '1', '0', '2',
                '1023309', '25266', '7473', 'True', 'Running', '0'
            ],
            [
                'foobar_00022', 'eCommunicationsObjMgr_esn',
                '17348',        '35',
                '0',            '0',
                '7',            '1018254',
                '30321',        '6454',
                'True',         'Running',
                '0'
            ],
            [
                'foobar_00022', 'EAIObjMgr_esn', '17042', '21', '0', '0', '11',
                '911310', '137265', '78270', 'True', 'Running', '0'
            ],
            [
                'foobar_00022', 'EAIObjMgr_esn', '17008', '19', '0', '0', '11',
                '894912', '153663', '96884', 'True', 'Running', '0'
            ],
            [
                'foobar_00022', 'AsgnSrvr', '16918', '13',
                '0',            '0',        '26',    '966760',
                '81815',        '58702',    'True',  'Running',
                '0'
            ],
            [
                'foobar_00022', 'WfProcMgr', '16898', '14',
                '0',            '0',         '27',    '913785',
                '134790',       '76080',     'True',  'Running',
                '0'
            ],
            [
                'foobar_00022', 'eCommunicationsObjMgr_esn',
                '17375',        '38',
                '0',            '0',
                '7',            '1018205',
                '30370',        '6462',
                'True',         'Running',
                '0'
            ],
            [
                'foobar_00022', 'eCommunicationsObjMgr_esn',
                '17300',        '34',
                '0',            '0',
                '7',            '1018074',
                '30501',        '6429',
                'True',         'Running',
                '0'
            ],
            [
                'foobar_00022', 'eSalesCMEObjMgr_esn', '17253', '31', '0', '0',
                '7', '1018680', '29895', '6408', 'True', 'Running', '0'
            ],
            [
                'foobar_00022', 'ServerMgr', '17983', '83', '1', '0', '2',
                '1023309', '25266', '7597', 'True', 'Running', '0'
            ],
            [
                'foobar_00022', 'XMLPReportServer', '16921', '15', '0', '0',
                '26', '956648', '91927', '37434', 'True', 'Running', '0'
            ],
            [
                'foobar_00022', 'FSMSrvr', '16751', '5',
                '0',            '0',       '26',    '1033214',
                '15361',        '3999',    'True',  'Running',
                '0'
            ],
            [
                'foobar_00022', 'eProdCfgObjMgr_esn', '17116', '24', '0', '0',
                '7', '1017382', '31193', '7008', 'True', 'Running', '0'
            ],
            [
                'foobar_00022', 'SCCObjMgr_esn', '16938', '16', '0', '0', '7',
                '1018715', '29860', '6363', 'True', 'Running', '0'
            ],
            [
                'foobar_00022', 'eCommunicationsObjMgr_esn',
                '17276',        '32',
                '0',            '0',
                '7',            '1018120',
                '30455',        '6435',
                'True',         'Running',
                '0'
            ],
            [
                'foobar_00022', 'ServerMgr', '18515', '84', '1', '0', '2',
                '1023306', '25269', '7603', 'True', 'Running', '0'
            ],
            [
                'foobar_00022', 'ServerMgr', '20182', '85', '1', '0', '2',
                '1023309', '25266', '7575', 'True', 'Running', '0'
            ],
            [
                'foobar_00022', 'eChannelObjMgr_esn', '16954', '17', '0', '0',
                '7', '1018674', '29901', '6450', 'True', 'Running', '0'
            ],
            [
                'foobar_00022', 'EAIObjMgr_esn', '17078', '23', '0', '0', '9',
                '902673', '145902', '93201', 'True', 'Running', '0'
            ],
            [
                'foobar_00022', 'WfRecvMgr', '16879', '12', '0', '0', '26',
                '954097', '94478', '38322', 'True', 'Running', '0'
            ],
            [
                'foobar_00022', 'eCommunicationsObjMgr_esn',
                '17264',        '33',
                '0',            '0',
                '7',            '1018175',
                '30400',        '6431',
                'True',         'Running',
                '0'
            ],
            [
                'foobar_00022', 'CommConfigMgr', '17165', '27', '0', '0', '26',
                '954502', '94073', '38215', 'True', 'Running', '0'
            ],
            [
                'foobar_00022', 'ServerMgr', '5218', '43', '1', '0', '2',
                '1022748', '25827', '7305', 'True', 'Running', '0'
            ],
            [
                'foobar_00022', 'SvrTaskPersist', '16791', '8', '1', '0', '3',
                '961867', '86708', '40653', 'True', 'Running', '0'
            ],
            [
                'foobar_00022', 'AdminNotify', '16811', '7', '0', '0', '17',
                '1035857', '12718', '2546', 'True', 'Running', '0'
            ],
            [
                'foobar_00022', 'eCustomerObjMgr_esn', '17135', '26', '0', '0',
                '7', '1018809', '29766', '6415', 'True', 'Running', '0'
            ],
            [
                'foobar_00022', 'CommInboundProcessor', '17233', '30', '0', '0',
                '56', '947471', '101104', '37566', 'True', 'Running', '0'
            ],
            [
                'foobar_00022', 'ServerMgr', '20537', '77', '1', '0', '2',
                '1023309', '25266', '7568', 'True', 'Running', '0'
            ],
            [
                'foobar_00022', 'SCBroker', '16739', '4', '1', '0', '2',
                '1040277', '8298', '1923', 'True', 'Running', '0'
            ],
            [
                'foobar_00022', 'eSalesObjMgr_esn', '17096', '25', '0', '0',
                '7', '1018715', '29860', '6357', 'True', 'Running', '0'
            ],
            [
                'foobar_00022', 'eCommunicationsObjMgr_esn',
                '17404',        '39',
                '0',            '0',
                '7',            '1018237',
                '30338',        '6407',
                'True',         'Running',
                '0'
            ],
            [
                'foobar_00022', 'SiebSrvr', '16583', '1', '2', '0', '2',
                '1039129', '9446', '6664', 'True', 'Running', '0'
            ],
            [
                'foobar_00022', 'CommOutboundMgr', '17215', '29', '0', '0',
                '56', '943611', '104964', '38714', 'True', 'Running', '0'
            ],
            [
                'foobar_00022', 'SvrTblCleanup', '16752', '9', '1', '0', '3',
                '955067', '93508', '47411', 'True', 'Running', '0'
            ],
            [
                'foobar_00022', 'SCBroker', '16733', '3', '1', '0', '2',
                '1040242', '8333', '1929', 'True', 'Running', '0'
            ],
            [
                'foobar_00022', 'ServerMgr', '6278', '82', '1', '0', '2',
                '1023309', '25266', '6785', 'True', 'Running', '0'
            ],
            [
                'foobar_00022', 'SRBroker', '16732', '2',
                '42',           '0',        '10',    '1013049',
                '35526',        '8328',     'True',  'Running',
                '0'
            ],
            [
                'foobar_00022', 'WorkMonSWI', '16893', '10', '1', '0', '3',
                '989486', '59089', '38312', 'True', 'Running', '0'
            ],
            [
                'foobar_00022', 'WfProcBatchMgr', '16865', '11', '0', '0', '26',
                '953833', '94742', '38442', 'True', 'Running', '0'
            ],
            [
                'foobar_00022', 'EAIObjMgr_esn', '17022', '20', '0', '0', '11',
                '861085', '187490', '131421', 'True', 'Running', '0'
            ],
            [
                'foobar_00022', 'eCommunicationsObjMgr_esn',
                '17337',        '36',
                '0',            '0',
                '7',            '1018164',
                '30411',        '6468',
                'True',         'Running',
                '0'
            ],
            [
                'foobar_00022', 'CommInboundRcvr', '17198', '28', '0', '0',
                '35', '947592', '100983', '40317', 'True', 'Running', '0'
            ],
            [
                'foobar_00022', 'SRProc', '16805', '6',
                '2',            '0',      '6',     '997548',
                '51027',        '30713',  'True',  'Running',
                '0'
            ],
            [
                'foobar_00022', 'EAIObjMgr_esn', '17062', '22', '0', '0', '11',
                '922842', '125733', '68339', 'True', 'Running', '0'
            ],
            [
                'foobar_00022', 'EAIObjMgr_esn', '16992', '18', '0', '0', '11',
                '898998', '149577', '92718', 'True', 'Running', '0'
            ]
        ]
    };

}

1;

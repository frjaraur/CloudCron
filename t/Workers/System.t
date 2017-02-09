use Test::Spec;
use strict;
use CloudCron::Workers::System;
use CloudCron::TargetInput;
use CloudCron::Compiler;
use Data::Dumper;
#use Mocks;

describe "CloudCron::Workers::System" => sub {

    my $log_stub = stub(
        error => sub { print STDERR "\nE: " . shift . "\n"; },
        warn  => sub {},
        info  => sub {},
        debug => sub {},
    );

    my $sqs_mock = stub(
        ReceiveMessage => sub {
            return stub(
                Messages => [
                    stub(
                        ReceiptHandle => 'abcdefg',
                        Body => 'I am the message',
                    )
                ]
            );
        },
        DeleteMessage => sub { },
        isa => sub { 'Paws::SQS' },
    );
    #my $log_stub = mock_log();
    #my $sqs_mock = mock_sqs();

    my $worker;
    before each => sub {
        $worker = CloudCron::Workers::System->new({
            queue_url => '',
            region => '',
            sqs => $sqs_mock,
            log => $log_stub,
        });
        #
    };

    it "can fetch message" => sub {
        my $expectation = $worker->expects('process_message')->once;
        $worker->fetch_message;
        ok($expectation->verify);
    };

    it "can fetch 2 messages" => sub {
        my $expectation = $worker->expects('process_message')->exactly(2)->times;
        $worker->fetch_message;
        $worker->fetch_message;
        ok($expectation->verify);
    };

    it "receives a correct message" => sub {
        my $expectation = $worker
            ->expects('process_message')
            ->with_deep(stub(Body => 'I amb the message'));
        $worker->fetch_message;
        ok($expectation->verify);
    };
};

runtests unless caller;
1;

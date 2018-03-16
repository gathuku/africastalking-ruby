RSpec.describe AfricasTalking do

	before(:each) do
	    @gateway=AfricasTalking::Gateway.new('sandbox', 'bed6bd70401f3110e7f8c347b0819efa7012f64f689b3c0fa8dd1f452224861b', 'sandbox')
	end

	it "has a version number" do
		expect(AfricasTalking::VERSION).not_to be nil
	end

	# ///////////////////SMS////////////////////////

	it "should be able to send bulk message" do
		# p @gateway
		sms = @gateway.sms
		expect(sms.sendMessage 'sample message', "+25472232#{rand(1000...9999)}, +25476334#{rand(1000...9999)}").to inspect_StatusReport(include(status: "Success"))
		
	end

	it "should be able to fetch messages" do
		sms = @gateway.sms
		expect(sms.fetchMessages)
		# expect(@gateway.fetch_messages).to inspect_SMSMessages
	end

	# not completed this test. remember to consider empty responses
	it "should be able to fetch subscriptions" do
		# p @gateway.fetch_messages
		sms = @gateway.sms
		expect(sms.fetchSubscriptions '77777', 'gemtests', '')
	end	

	# not complete. you need to check what the checkoutToken is
	it "should be able to create subscriptions" do
		# p @gateway.fetch_messages
		sms = @gateway.sms
		expect(sms.createSubcriptions '77777', 'gemtests', '0722222222', 'checkoutToken')
	end

	it "should send premium message" do
		sms = @gateway.sms
		expect(sms.sendPremiumMessage 'sample message', 'gemtests', 'linkId', ["+25472232#{rand(1000...9999)}, +25476334#{rand(1000...9999)}"])
	end



	# ///////////////////AIRTIME//////////////////////

	it "should be able to send airtime to a phone number" do 
		airtime = @gateway.airtime
		recipients = [
			{'phoneNumber' => "+25472232#{rand(1000...9999)}", 'amount' => 'KES 100'},
			{'phoneNumber' => "+25476334#{rand(1000...9999)}", 'amount' => 'KES 100'}
		]
		expect(airtime.sendAirtime recipients).to inspect_AirtimeResult(include(status: "Sent"))
	end

	# ////////////////////////////////////////////

	# ////////////////////////////VOICE///////////////////////////////////

	it "should be able to make call" do
		voice = @gateway.voice
		to = ['+254722222222', '+254733333333']
		from = '+254722123456'

		expect(voice.call to, from).to inspect_CallResponse(include(status: "Queued"))
	end


	it "should be able to fetch queued calls" do
		voice = @gateway.voice
		phoneNumber = '+254722123456'

		expect(voice.fetchQueuedCalls phoneNumber, nil)
	end

	# ///////////////////////////////////////////////////////////////////


	# /////////////////////////PAYMENTS////////////////////////////

	it "initiate initiate Mobile Payment Checkout" do
		payments = @gateway.payments
		expect(payments.initiateMobilePaymentCheckout 'RUBY_GEM_TEST', '0722232323',  'KES', '200' )

	end

	it "initiate mobile B2C payment" do
		payments = @gateway.payments
		recipients = [
			{
				"name" => "Payments Test",
			    "phoneNumber"=> '+254722222222',
			    "currencyCode"=> "KES",
			    "amount"=> '100',
			    "reason"=> "SalaryPayment",
			    "metadata" => {
			       "description" => "test employee",
			       "employeeId" => "123"
			    }
			},
			{
				"name" => "Payments Test",
			    "phoneNumber"=> '+254722333322',
			    "currencyCode"=> "KES",
			    "amount"=> '2000',
			    "reason"=> "SalaryPayment",
			    "metadata" => {
			       "description" => "test employee",
			       "employeeId" => "123"
			    }
			}
		]
		expect(payments.mobilePaymentB2CRequest  'RUBY_GEM_TEST' ,recipients)
		
	end

	it "initiate mobile B2B request" do
		payments = @gateway.payments
		providerData = {
	        'provider' => 'Athena',
	        'destinationChannel' => '121212',
	        'destinationAccount' => 'destinationAccount',
	        'transferType' => 'BusinessToBusinessTransfer'
       	}
       	metadata = {
            'shopId' => "1234",
            'itemId' => "abcde"
        }
		expect(payments.mobilePaymentB2BRequest 'RUBY_GEM_TEST', providerData, 'KES', '100.50', metadata = {} )
		
	end

	it "initiate bank charge checkout" do
		payments = @gateway.payments
		bankAccount = {
	        'accountName' => 'Test Bank Account',
	        'accountNumber' => '1234567890',
	        'bankCode' => 234001,
	        'dateOfBirth' => '2017-11-22'
       	}
       	metadata = {
            'requestId' => "1234",
            'applicationId' => "abcde"
        }
        narration = 'This is a test transaction'

		expect(payments.initiateBankChargeCheckout 'RUBY_GEM_TEST', bankAccount, 'KES', '500.50', narration, metadata = {} )
	end

	it "validate bank account checkout" do
		payments = @gateway.payments
		expect(payments.validateBankAccountCheckout 'ATPid_SampleTxnId1', '1234' )
	end

	it "initiate bank transfer request" do
		payments = @gateway.payments
		recipient1 = {
			'bankAccount' => {
				'accountName' => 'Test Bank Account',
		        'accountNumber' => "123456#{rand(1000...9999)}",
		        'bankCode' => 234001
			},
	        'currencyCode' => 'KES',
	        'amount' => "200.00",
            'narration' => 'This is a test transaction e.g. Salary Payment ',
            'metadata' => {
	       		"description" => "May Salary",
	       		"departmentId" => "124"
	       	}
       	}
       	recipient2 = {
       		'bankAccount' => {
				'accountName' => 'Second Test Bank Account',
		        'accountNumber' => "098765#{rand(1000...9999)}",
		        'bankCode' => 234009
			},
	        'currencyCode' => 'KES',
	        'amount' => "5000.00",
            'narration' => 'This is a test transaction 2 e.g. Salary Payment ',
            'metadata' => {
	       		"description" => "May Salary",
	       		"departmentId" => "125"
	        }
       	}
       	recipients = [ recipient1, recipient2 ]
		expect(payments.initiateBankTransferRequest 'RUBY_GEM_TEST', recipients )
	end

	it "initiate card checkout" do
		payments = @gateway.payments
		paymentCard = {
	        "number"=> "5105105105105100",
	        "cvvNumber"=> 654,
	        "expiryMonth"=> 9,
	        "expiryYear"=> 2020,
	        "countryCode"=> "NG",
	        "authToken"=> "12345",
	    }
		expect(payments.initiateCardCheckout 'RUBY_GEM_TEST', 'KES', '1200', 'test narration', nil, paymentCard, nil )
	end

	it "validate card checkout" do
		payments = @gateway.payments
		expect(payments.validateCardCheckout 'ATPid_39a71bc00951cd1d3ed56d419d0ab3b6', '1234' )
	end

	it 'initiate wallet transfer request' do 
		payments = @gateway.payments
		metadata = {
	        "description" => "May Rent"
	    }
		expect(payments.walletTransferRequest 'RUBY_GEM_TEST', 2373, 'KES', 2000, metadata )
	end

	it 'initiate topup stash request' do 
		payments = @gateway.payments
		metadata = {
	        "description" => "moving money"
	    }
		expect(payments.topupStashRequest 'RUBY_GEM_TEST', 'KES', 2000, metadata )
	end

	# ///////////////////////////////////////////////////////////////////


end

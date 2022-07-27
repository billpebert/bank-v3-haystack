<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Tests\TestCase;
use App\Model\Accounts;
use App\Model\Accounttypes;
use App\Model\Accountclass;
use App\Model\Cashbook1;

class MainTest extends TestCase
{
    use RefreshDatabase;


    /**
     *  Transaction page type bank
     *
     * @return void
     */
    public function test_Bank_Transaction()
    {

        $this->withoutExceptionHandling();
        $account = factory(Accounts::class)->create();

        $response = $this->post('transaction', ['bankShareVar' => 'bank', 'accounts' => $account->id, 'startdate' => '2022-01-01', 'finishdate' => '2022-01-31']);
        $response->assertStatus(200);
    }

    /**
     *  Transaction page type share
     *
     * @return void
     */
    public function test_Share_Transaction()
    {

        $this->withoutExceptionHandling();
        $account = factory(Accounts::class)->create();

        $response = $this->post('transaction', ['bankShareVar' => 'shares', 'accounts' => $account->id, 'startdate' => '2022-01-01', 'finishdate' => '2022-01-31']);
        $response->assertStatus(200);
    }

    /**
     *  Auto suggestion 
     *
     * @return void
     */
    public function test_auto_suggestion_details_field()
    {
        $accName = 'Acc1';
        $input = 'a';
        $entry = 'Details';
        $this->withoutExceptionHandling();
        $checkAccExist = Accounts::where('AccountName', '=', $accName)->first();
        if ($checkAccExist == null) {
            $account = factory(Accounts::class)->create([
                'AccountName' => $accName,
                'AccountFK' => factory(Accounttypes::class)->create()->id,
            ]);
        } else {
            $account = $checkAccExist->AccountID;
        }

        $Cashbook = factory(Cashbook1::class)->create([
            'creditFK' => $account,
            'details' => $accName,
        ]);
        $response = $this->get('autosuggestion?entry=' . $entry . '&account=' . $accName . '&input=' . $input);
        $response->assertStatus(200);
        $result = array('id' => 1, 'value' => $accName, 'info' => '');
        $response->assertExactJson(
            [
                'results' => [$result]
            ]
        );
    }

    /**
     *  Auto suggestion 
     *
     * @return void
     */
    public function test_auto_suggestion_from_field()
    {
        $accName = 'Acc1';
        $input = 'Acc1';
        $entry = '';
        $this->withoutExceptionHandling();
        $checkAccExist = Accounts::where('AccountName', '=', $accName)->first();
        if ($checkAccExist == null) {
            $account = factory(Accounts::class)->create([
                'AccountName' => $accName,
                'AccountFK' => factory(Accounttypes::class)->create()->id,
            ]);
        } else {
            $account = $checkAccExist;
        }

        $accType = Accounttypes::where('AccountFK', '=', $account->AccountFK)->first();

        $response = $this->get('autosuggestion?entry=' . $entry . '&account=&input=' . $input . '&divSafe=true');
        $response->assertStatus(200);
        $result = array('id' => 1, 'value' => $accName, 'info' => $accType->AccountTypesName);
        $response->assertExactJson(
            [
                'results' => [$result]
            ]
        );
    }

    /**
     *  Save transaction bank 
     *
     * @return void
     */

    public function test_save_transaction_bank()
    {
        $account = factory(Accounts::class)->create();
        $fromVar = 'Acc1';
        $accountVar = $account->id;
        $startDateVar = '2022-01-31';
        $finishDateVar = '2022-01-01';
        $bankShareVar = 'bank';
        $dateVar = '2022-01-17';
        $detailsVar = 'details';
        $amountVar = 125;
        $fxDetails = '£';
        $segmentVar = 'segment';
        $chequeVar = 0.10;
        $fxRate = 1;
        $fullCatVar = 'fullcat';
        $credDeb = 'credit';
        $catVar = 2;
        $taxVar = 4;

        $this->withoutExceptionHandling();


        $response = $this->post(
            'saveTransactionBank',
            [
                'fromVar' => $fromVar,
                'accountVar' => $accountVar,
                'startDateVar' => $startDateVar,
                'finishDateVar' => $finishDateVar,
                'bankShareVar' => $bankShareVar,
                'dateVar' => $dateVar,
                'detailsVar' => $detailsVar,
                'amountVar' => $amountVar,
                'fxDetails' => $fxDetails,
                'segmentVar' => $segmentVar,
                'chequeVar' => $chequeVar,
                'fxRate' => $fxRate,
                'fullCatVar' => $fullCatVar,
                'credDeb' => $credDeb,
                'catVar' => $catVar,
                'taxVar' => $taxVar
            ]
        );
        $response->assertStatus(200);
        $response->assertExactJson(
            [
                'status' => 'success', 'message' => 'Transaction created successfull'
            ]
        );
    }
}

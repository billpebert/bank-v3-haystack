<?php

namespace App\Http\Controllers;

use App\Http\Requests\TransactionShareRequest;
use Couchbase\View;
use DB;
use Illuminate\Http\Request;
use Redirect;
use Route;

/**
 * GENERAL NOTES: 
 * 
 *  1- I didn't change the database fields name (that's why var names in the queries are still the same)
 * 
 *  2- You can't use empty() with strings it can cause problems
 * 
 */

class MainController extends Controller
{
    /**
     * Function: Index
     * 
     * Description: (Please add your description here.)
     * 
     * Return type: View
     */
    public function index()
    {
        $accounts = DB::table('accounts')->whereIn('AccountFK', [3, 20])->get();
        return view('Pages.index', compact('accounts'));
    }


    /**
     * Function: Transaction
     * 
     * Description: (Please add your description here.)
     * 
     * Return type: View
     */
    public function transaction(Request $request)
    {

        // dd($request->accounts);
        $accounts = $request->accounts;
        if ($request->bankShare === 'bank') {
            $currency = DB::table('accounts')
                ->select('currency')
                ->where('accountid', $accounts)
                ->get();

            return view('Pages.transaction_bank', ['currency' => $currency]);
        } else {
            // return view('Pages.transaction_share');
            return view('Pages.transaction_share', compact('accounts'));
        }
    }


    /**
     * Function: Output
     * 
     * Description: (Please add your description here.)
     * 
     * Return type: JSON
     */
    public function output(Request $request)
    {
        $input = $request->input;

        $result = DB::select(
            "select * from (
                select 
                    cashid,
                    amount,
                    cat, 
                    fullcat, 
                    cheque, 
                    details, 
                    segment, 
                    credit, 
                    debit 
                from joinedcashbook
                where ( 
                        trim(lower(debit))='" . strtolower($input['value']) . "' 
                    or 
                        trim(lower(credit))='" . strtolower($input['value']) . "'
                )
                order by tstamp desc limit 3
            ) as t2
            left join (
                select percent 
                from suggesttax,accounts 
                where (
                        trim(lower(accountname))= '" . strtolower($input['value']) . "'
                    and 
                        accountfk=actype 
                    and 
                        taxcountry=country
                ) 
                limit 1
            ) as t1 
            on cashid is not null or percent is not null 
            limit 1;"
        );

        return response()->json($result);
    }


    /**
     * Function: Auto suggestion
     * 
     * Description: (Please add your description here.)
     * 
     * Return type: JSON
     */
    public function autoSuggestion(Request $request)
    {
        if (!$request->entery) {
            //In case entery is missing
            $resultObject = DB::select('call suggest(?,?)', [$request->input, $request->divSafe]);
            $result = [];
            foreach ($resultObject as $key => $item) {
                $result[] = ['id' => $key + 1, 'value' => $item->AccountName, 'info' => $item->AccountTypesName];
            }
        } else {
            //In case entery is not missing
            $resultObject = DB::select(
                "select distinct " . $request->entry . " 
                from cashbook1,accounts 
                where (
                        lower(accountname) = '" . strtolower($request->account) . "'
                    and (
                        lower(" . $request->entry . ") like '%" . strtolower($request->input) . "%') 
                    and (
                        accountid=debitfk or accountid=creditfk
                        )
                    ) 
                limit 35;"
            );

            $result = [];

            foreach ($resultObject as $key => $item) {
                $arrItem  = (array) $item;
                $result[] = [
                    'id' => $key + 1,
                    'value' => $arrItem[$request->entry],
                    'info' => ''
                ];
            }
        }

        return response()->json(['results' => $result]);
    }


    /**
     * Function: Save new transaction
     * 
     * Description: (Please add your description here.)
     * 
     * Return type: JSON
     */
    public function saveTransactionBank(Request $request)
    {
        //Initiate data
        $transaction['finishDateVar'] = $request->finishDateVar;
        $transaction['bankShareVar']  = $request->bankShareVar;
        $transaction['startDateVar']  = $request->startDateVar;
        $transaction['accountVar']    = $request->accountVar;
        $transaction['detailsVar']    = $request->detailsVar;
        $transaction['fullCatVar']    = $request->fullCatVar;
        $transaction['amountVar']     = $request->amountVar;
        $transaction['fxDetails']     = $request->fxDetails;
        $transaction['fromVar']       = $request->fromVar;
        $transaction['dateVar']       = $request->dateVar;
        $transaction['credDeb']       = $request->credDeb;
        $transaction['catVar']        = $request->catVar;
        $transaction['fxVar']         = $request->fxRate;

        //Check for null data
        $transaction['segmentVar']    = $request->segmentVar === ""
            ? "NULL"
            : $request->segmentVar;
        $transaction['chequeVar']     = $request->chequeVar === ""
            ? "NULL"
            : $request->chequeVar;
        $transaction['taxVar']        = $request->taxVar === ""
            ? "NULL"
            : $request->taxVar;


        $transaction['amountVar']     = round($transaction['amountVar'] / $transaction['fxVar'], 2);
        $transaction['detailsVar']    = $transaction['fxVar'] != "1"
            ? $transaction['detailsVar'] . ' ' . $transaction['fxDetails'] . $transaction['amountVar']
            : $transaction['detailsVar'];


        //Check if fromVar is missing
        if (!$transaction['fromVar']) {
            $result = ['status' => 'error', 'message' => 'Failed when creating transaction (Account is missing)'];
        } else {
            $checkAccount = DB::select('call getaccountfk(?)', [$transaction['fromVar']]);

            //Check if account exists
            if (count($checkAccount)) {
                $fromFk = $checkAccount[0]->accountid;

                $segmentVar = !$transaction['segmentVar'] ? "NULL" : $transaction['segmentVar'];
                $chequeVar  = !$transaction['chequeVar'] ? "NULL" : $transaction['chequeVar'];
                $catVar     = !$transaction['catVar'] ? "NULL" : $transaction['catVar'];
                $taxVar     = !$transaction['taxVar'] ? "NULL" : $transaction['taxVar'];

                if ($transaction['credDeb'] === "credit") {
                    $creditVar = $fromFk;
                    $debitVar  = $transaction['accountVar'];
                } else {
                    $creditVar = $transaction['accountVar'];
                    $debitVar  = $fromFk;
                }

                //Save transaction
                try {
                    DB::select(
                        "call accountupdate(
                        '" . $transaction['dateVar'] . "',
                        '" . $transaction['amountVar'] . "',
                        '" . $catVar . "', 
                        '" . $transaction['fullCatVar'] . "',
                        '" . $creditVar . "',
                        '" . $debitVar . "',
                        '" . $transaction['detailsVar'] . "',
                        '" . $segmentVar . "',
                        " . $chequeVar . ",
                        " . $taxVar . ",
                        '" . $transaction['credDeb'] . "',
                        " . $transaction['fxVar'] . "
                        )"
                    );

                    //Transaction success
                    $result = ['status' => 'success', 'message' => 'Transaction created successfull'];
                } catch (Trowable $e) {
                    //Transaction canceled (throwed error)
                    $result = ['status' => 'error', 'message' => $e];
                }
            } else {
                //Return error message in case of null (no account found)
                $result = ['status' => 'notFound', 'message' => 'Account not found'];
            }
        }

        //Return result
        return response()->json($result);
    }


    /**
     * Function: Create account
     * 
     * Description: (Please add your description here.)
     * 
     * Return type: View
     */
    public function createAccount(Request $request)
    {
        $accountTypes = DB::table('accounttypes')
            ->select('AccountTypesName', 'AccountFK')
            ->get();

        return view('Pages.create_account', compact('accountTypes'));
    }

    /**
     * Function: Save account
     * 
     * Description: (Please add your description here.)
     * 
     * Return type: JSON
     */
    public function saveAccount(Request $request)
    {
        //Initiate data
        $account['accountTypeIdVar'] = $request->accountTypeId;
        $account['finishDateVar'] = $request->finishDateVar;
        $account['bankShareVar'] = $request->bankShareVar;
        $account['startDateVar'] = $request->startDateVar;
        $account['accountVar'] = $request->accountVar;
        $account['fullCatVar'] = $request->fullCatVar;
        $account['detailsVar'] = $request->detailsVar;
        $account['fxDetails'] = $request->fxDetails;
        $account['amountVar'] = $request->amountVar;
        $account['fromVar'] = $request->fromVar;
        $account['dateVar'] = $request->dateVar;
        $account['credDeb'] = $request->credDeb;

        //Check null data
        $account['segmentVar'] = $request->segmentVar === null
            ? "NULL"
            : $request->segmentVar;
        $account['chequeVar'] = $request->chequeVar === null
            ? "NULL"
            : $request->chequeVar;
        $account['catVar'] = $request->catVar === null
            ? "NULL"
            : $request->catVar;
        $account['taxVar'] = $request->taxVar === null
            ? "NULL"
            : $request->taxVar;
        $account['fxVar'] = $request->fxRate === null
            ? "NULL"
            : $request->fxRate;


        $detailsVar = $account['fxVar'] != "1"
            ? $account['detailsVar'] . ' ' . $account['fxDetails'] . $account['amountVar']
            : $account['detailsVar'];


        $amountVar = round($account['amountVar'] / $account['fxVar'], 2);

        try {
            //Create account
            DB::select(
                "call newaccount(
                    '" . $account['dateVar'] . "', 
                    '" . $amountVar . "', 
                    " . $account['catVar'] . ", 
                    '" . $account['fullCatVar'] . "',
                    '" . $account['fromVar'] . "',
                    '" . $account['accountVar'] . "',
                    '" . $account['accountTypeIdVar'] . "',
                    '" . $account['credDeb'] . "',
                    '" . $detailsVar . "',
                    '" . $account['segmentVar'] . "',
                    " . $account['chequeVar'] . ",
                    " . $account['taxVar'] . ",
                    '" . $account['fxVar'] . "'
                )"
            );
            $result = ['status' => 'success', 'message' => 'Account created successfull'];
        } catch (Trowable $e) {
            $result = ['status' => 'error', 'message' => $e];
        }

        //Return result
        return response()->json($result);
    }


    /**
     * Function: Save transaction share
     * 
     * Description: (Please add your description here.)
     * 
     * Return type: JSON
     */
    public function saveTransactionShare(Request $request)
    {
        //Initiate data
        $transaction['fxVar']              = $request->fxVar;
        $transaction['dateVar']            = $request->dateVar;
        $transaction['fromVar']            = $request->fromVar;
        $transaction['credDeb']            = $request->credDeb;
        $transaction['grossVar']           = $request->grossVar;
        $transaction['amountVar']          = $request->amountVar;
        $transaction['numberVar']          = $request->numberVar;
        $transaction['detailsVar']         = $request->detailsVar;
        $transaction['accountVar']         = $request->accountVar;
        $transaction['startDateVar']       = $request->startDateVar;
        $transaction['bankShareVar']       = $request->bankShareVar;
        $transaction['finishDateVar']      = $request->finishDateVar;
        $transaction['transactionTimeVar'] = $request->transactionTimeVar;

        //Check for null data
        $transaction['segmentVar'] = $request->segmentVar === ""
            ? "NULL"
            : $request->segmentVar;

        $transaction['chequeVar']  = $request->chequeVar === ""
            ? "NULL"
            : $request->chequeVar;
        $transaction['taxVar']    = $request->taxVar === ""
            ? "NULL"
            : $request->taxVar;

        if ($transaction['credDeb'] === 'credit') {
            $numberDebitedVar  = $transaction['numberVar'];
            $numberCreditedVar = 0;
        } else {
            $numberCreditedVar = $transaction['numberVar'];
            $numberDebitedVar  = 0;
        }

        $commissionVar = $transaction['grossVar'] === ""
            ? 0
            : abs($transaction['amountVar'] - $transaction['grossVar']);


        //Get account
        $checkCompany = DB::select('call getaccountfk(?)', [$transaction['fromVar']]);

        if (count($checkCompany) > 0) {
            //Account found
            $fromFk = $checkCompany[0]->accountid;

            if ($transaction['credDeb'] === "debit") {
                $creditVar = $fromFk;
                $debitVar  = $transaction['accountVar'];
            } else {
                $creditVar = $transaction['accountVar'];
                $debitVar  = $fromFk;
            }

            //Create transaction
            try {
                DB::select(
                    "call shareupdate(
                            '" . $transaction['dateVar'] . "', 
                            " . $transaction['amountVar'] . ", 
                            " . $creditVar . ",
                            " . $debitVar . ",
                            '" . $transaction['detailsVar'] . "',
                            '" . $transaction['segmentVar'] . "',
                            " . $numberCreditedVar . ",
                            " . $numberDebitedVar . ",
                            " . $commissionVar . ", 
                            " . $transaction['fxVar'] . ",
                            '" . $transaction['transactionTimeVar'] . "'
                        )"
                );

                $result = ['status' => 'success', 'message' => 'Transaction created successfull'];
            } catch (Trowable $e) {
                $result = ['status' => 'error', 'message' => $e];
            }
        } else {
            //Account not found
            $result = ['status' => 'notFound', 'message' => 'Not found account'];
        }

        //Return result
        return response()->json($result);
    }

    /**
     * Function: Save transaction share
     * 
     * Description: (Please add your description here.)
     * 
     * Return type: JSON
     */
    public function updateTransactionShare(Request $request)
    {
        //$getData = DB::table('cashbook1')->where('cashID', $request->cashID)->first();
        $startDate = $request->startdate;
        $finishDate = $request->finishdate;
        $accounts = $request->accounts;
        $data = $request->except(['_token', '_method', 'finishDateVar', 'startDateVar', 'bankShareVar', 'cashID', 'credDeb', 'fromVar']);
        $tb['Date'] = $data['dateVar'];
        $tb['Amount'] = $data['amountVar'];
        $tb['transactiontime'] = $data['transactionTimeVar'];
        // $tb['Amount'] = $data['fromVar'];
        $tb['commission'] = $data['amountVar'] - $data['grossVar'];
        $tb['Numbercredited'] = $data['numberVar'];
        $tb['Numberdebited'] = $data['numberVar'];
        $tb['Details'] = $data['detailsVar'];
        $tb['segment'] = $data['segmentVar'];
        $tb['fx'] = $data['fxVar'];
        // $tb['Amount'] = $data['credDeb'];
        //$tb['Amount'] = $data['accountVar'];
        DB::table('cashbook1')->where('cashID', $request->cashID)->update($tb);
        // dd($tb);
        return redirect()->route('transaction');
    }

    /**
     * Function: Create company
     * 
     * Description: (Please add your description here.)
     * 
     * Return type: View
     */
    public function createCompany(Request $request)
    {
        //Initiate data
        $numberVar = $request->numberVar;
        $credDeb   = $request->credDeb;
        $grossVar  = $request->grossVar;
        $amountVar = $request->amountVar;

        if ($credDeb === 'credit') {
            $numberDebitedVar  = $numberVar;
            $numberCreditedVar = 0;
        } else {
            $numberCreditedVar = $numberVar;
            $numberDebitedVar  = 0;
        }

        $commissionVar = $grossVar === ""
            ? 0
            : abs($amountVar - $grossVar);

        $accountTypes  = DB::table('accounttypes')
            ->select('AccountTypesName', 'AccountFK')
            ->get();
        $companyNames  = DB::table('segmentsjoined')
            ->select('SegmentName', 'SegmentID')
            ->where('segmentGroupsID', 5)
            ->get();

        return view(
            'Pages.create_company',
            compact(
                'accountTypes',
                'companyNames',
                'numberDebitedVar',
                'numberCreditedVar',
                'commissionVar'
            )
        );
    }


    /**
     * Function: Save company
     * 
     * Description: (Please add your description here.)
     * 
     * Return type: JSON
     */
    public function saveCompany(Request $request)
    {
        try {
            //Initiate data
            $company['fromVar']            = $request->fromVar;
            $company['accountVar']         = $request->accountVar;
            $company['accountTypeIdVar']   = $request->accountTypeId;
            $company['dateVar']            = $request->dateVar;
            $company['amountVar']          = $request->amountVar;
            $company['bankShareVar']       = $request->bankShareVar;
            $company['startDateVar']       = $request->startDateVar;
            $company['finishDateVar']      = $request->finishDateVar;
            $company['detailsVar']         = $request->detailsVar;
            $company['numberDebitedVar']   = $request->numberDebitedVar;
            $company['numberCreditedVar']  = $request->numberCreditedVar;
            $company['transactionTimeVar'] = $request->transactionTimeVar;
            $company['commission']         = $request->commission;
            $company['credDeb']            = $request->credDeb;
            $company['shareIdVar']         = $request->shareId;
            $company['currencyVar']        = $request->currency;
            $company['commissionVar']      = $request->commissionVar;

            //Check for null data
            $company['segmentVar']         = $request->segmentVar === ""
                ? "NULL"
                : $request->segmentVar;
            $company['bloomBergVar']       = $request->bloomBerg === ""
                ? "NULL"
                : $request->bloomBerg;
            $company['fxVar']         = $request->fxVar === ""
                ? 0
                : $request->fxVar;

            //Save company
            DB::select(
                "call newshare(
                    '" . $company['dateVar'] . "', 
                    '" . $company['amountVar'] . "', 
                    '" . $company['fromVar'] . "',
                    '" . $company['accountVar'] . "',
                    '" . $company['accountTypeIdVar'] . "',
                    '" . $company['credDeb'] . "',
                    '" . $company['detailsVar'] . "',
                    '" . $company['segmentVar'] . "',
                    '" . $company['bloomBergVar'] . "',
                    '" . $company['shareIdVar'] . "',
                    '" . $company['numberCreditedVar'] . "',
                    '" . $company['numberDebitedVar'] . "',
                    '" . $company['commissionVar'] . "', 
                    '" . $company['fxVar'] . "',
                    '" . $company['transactionTimeVar'] . "',
                    '" . $company['currencyVar'] . "')"
            );
            $result = ['status' => 'success', 'message' => 'Account created successfull'];
        } catch (Exception $e) {
            //Please choose one error output
            $result = ['status' => 'error', 'message' => 'Failed when creating company !!!'];
            $result = ['status' => 'error', 'message' => $e->getMessage()];
        }

        return response()->json($result);
    }

    /**
     * Function: Show Data For Edit
     * 
     * Description: (Please add your description here.)
     * 
     * Return type: JSON
     */
    public function showDataTransactionShare(Request $request)
    {
        $id = $request->id;
        $accounts = $request->acc;
        $startDate = $request->sd;
        $finishDate = $request->fd;

        $data = DB::table('cashbook1')->select('*')->join('accounts', 'cashbook1.creditFk', '=', 'accounts.AccountID')->where('cashId', $id)->first();

        $data->Amount = (int) $data->Amount;
        $data->Numbercredited = (int) $data->Numbercredited;
        $data->Numberdebited = (int) $data->Numberdebited;
        // dd($data->fx);

        return view('Pages.transaction_share_edit', compact('data', 'accounts', 'startDate', 'finishDate'));

        // try {
        //     $data = DB::table('cashbook1')->select('*')->join('accounts', 'cashbook1.creditFk', '=', 'accounts.AccountID')->where('cashId', $id)->get();

        //     $result = ['data' => $data, 'status' => '200', 'message' => 'Success'];
        // } catch (Trowable $e) {
        //     $result = ['status' => 'error', 'message' => $e];
        // }

        // return response()->json($result);
    }
}

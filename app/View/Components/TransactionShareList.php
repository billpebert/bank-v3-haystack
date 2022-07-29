<?php

namespace App\View\Components;

use DB;
use Illuminate\Support\Facades\DB as FacadesDB;
use Illuminate\View\Component;

class TransactionShareList extends Component
{

    /**
     * @var string
     */
    public $finishdate;

    /**
     * @var string
     */
    public $startdate;

    /**
     * @var string
     */
    public $accounts;

    /**
     * Create a new component instance.
     *
     * @return void
     */
    public function __construct(string $finishdate, string $startdate, string $accounts)
    {
        $this->finishdate = $finishdate;
        $this->startdate = $startdate;
        $this->accounts = $accounts;
    }

    /**
     * Get the view / contents that represent the component.
     *
     * @return \Illuminate\View\View|string
     */
    public function render()
    {

        $startDate = $this->startdate;
        $finishDate = $this->finishdate;
        $accounts = $this->accounts;
        $transactions = FacadesDB::select('call statementtidy4(?,?,?)', array($startDate, $finishDate, $accounts));

        // BALANCE TODAY IS MOVED
        // $balanceToday = DB::select('select balancefn(?,?) as balance', array($this->accounts, now()));
        // $balanceToday = $balanceToday[0]->balance;
        // return view('components.transaction-share-list', ['transactions' => $transactions, 'accounts' => $this->accounts, 'balanceToday' => $balanceToday]);

        return view('components.transaction-share-list', compact('transactions', 'startDate', 'accounts', 'finishDate'));
    }
}

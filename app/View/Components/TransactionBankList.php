<?php

namespace App\View\Components;
use DB;
use Illuminate\View\Component;

class TransactionBankList extends Component
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
        
        $transactions = DB::select('call statementtidy4(?,?,?)',array($this->startdate, $this->finishdate, $this->accounts));
        $balanceToday = DB::select('select balancefn(?,?) as balance',array($this->accounts, now()));
        $balanceToday = $balanceToday[0]->balance;

        return view('components.transaction-bank-list',['transactions'=>$transactions, 'accounts'=>$this->accounts, 'balanceToday'=>$balanceToday]);
    }
}

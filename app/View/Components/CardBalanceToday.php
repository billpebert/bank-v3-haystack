<?php

namespace App\View\Components;

use Illuminate\Support\Facades\DB;
use Illuminate\View\Component;

class CardBalanceToday extends Component
{
    /**
     * Create a new component instance.
     *
     * @return void
     */
    public function __construct(string $account)
    {
        $this->account = $account;
    }

    /**
     * Get the view / contents that represent the component.
     *
     * @return \Illuminate\View\View|string
     */
    public function render()
    {
        // dd(array($this->account, now()));
        $balanceToday = DB::select('select balancefn(?,?) as balance', array($this->account, now()));
        $balanceToday = $balanceToday[0]->balance;
        return view('components.card-balance-today', compact('balanceToday'));
    }
}

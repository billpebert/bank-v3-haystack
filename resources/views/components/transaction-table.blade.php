<div class="table-responsive __transactions-table mt-4">
    <table class="table table-sm table-borderless">
        <tr class="table-active">
            <th scope="col">#</th>
            <th scope="col">Transaction ID</th>
            <th scope="col">Date</th>
            <th scope="col">Transaction Time</th>
            <th scope="col">Amount</th>
            <th scope="col">Payee/Payor</th>
        </tr>
        <tbody>
            @forelse ($transactions as $key => $item)
                <tr class="accordion-toggle collapsed" id="accordion1" data-toggle="collapse" data-parent="#accordion1"
                    href="#collapseOne">
                    <th scope="row">{{ $key + 1 }}</th>
                    <td class="__data-transaction-id">
                        <a href="#">{{ $item->cashid }}</a>
                    </td>
                    <td>
                        {{ $item->date }}
                    </td>
                    <td>
                        {{ $item->transactiontime }}
                    </td>
                    <td class="__data-transaction-amount">
                        + 2,500
                    </td>
                    @if ($accounts == $item->creditfk)
                        <td>{{ $item->debit }}</td>
                    @elseif ($accounts == $item->debitfk)
                        <td>{{ $item->credit }}</td>
                    @endif
                    <td type="button" data-toggle="collapse" data-target="#collapseExample" aria-expanded="false"
                        aria-controls="collapseExample" class="d-flex align-items-center justify-content-between">
                        {{ $item->details }}
                        <img src="{{ asset('svgs/ic_arrow-dropdown.svg') }}" alt="">
                    </td>
                </tr>
                <tr class="hide-table-padding">
                    <td></td>
                    <td colspan="5">
                        <div id="collapseOne" class="collapse paddingtd">
                            <div class="d-flex gap-3">
                                <div>
                                    <div class="font-semibold">Details</div>
                                    <div style="max-width: 260px;">
                                        {{ $item->details }}
                                    </div>
                                </div>
                                <div>
                                    <div class="font-semibold">No. credited</div>
                                    <div>
                                        {{ $item->numbercredited }}
                                    </div>
                                </div>
                                <div>
                                    <div class="font-semibold">No. debited name</div>
                                    <div>
                                        {{ $item->numberdebited }}
                                    </div>
                                </div>
                                <div>
                                    <div class="font-semibold">Commission</div>
                                    <div>
                                        {{ $item->commission }}
                                    </div>
                                </div>
                                <div>
                                    <div class="font-semibold">Fx</div>
                                    <div>
                                        {{ $item->fx }}
                                    </div>
                                </div>
                            </div>
                        </div>
                    </td>
                </tr>
            @empty
                {{-- Empty State --}}
                @component('components.empty-state')
                    @slot('title', 'No Transaction Data')
                    @slot('caption', 'Looks like there is no recent transaction addition')
                @endcomponent
            @endforelse
        </tbody>
    </table>
</div>

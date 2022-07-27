<div>
    <h4 class="mb-3">Balance today: {{ $balanceToday }}</h4>
    <div class="table-responsive">
        <table class="table table-striped table-bordered small">
            <thead>
                <tr>
                    <th scope="col">#</th>
                    <th scope="col">Transaction ID</th>
                    <th scope="col">Date</th>
                    <th scope="col">Credit</th>
                    <th scope="col">Debit</th>
                    <th scope="col">Payee/Payor</th>
                    <th scope="col">Details</th>
                    <th scope="col">Transaction time</th>
                    <th scope="col">No. credited</th>
                    <th scope="col">No. debited name</th>
                    <th scope="col">Commission</th>
                    <th scope="col">fx</th>
                </tr>
            </thead>
            <tbody>
                @forelse ($transactions as $key=> $item)
                    <tr>
                        <th scope="row">{{ $key + 1 }}</th>
                        <td>{{ $item->cashid }}</td>
                        <td>{{ $item->date }}</td>
                        @if ($accounts == $item->creditfk)
                            <td>{{ $item->amount }}</td>
                            <td></td>
                            <td>{{ $item->debit }}</td>
                        @elseif ($accounts == $item->debitfk)
                            <td></td>
                            <td style="color:crimson">{{ $item->amount }}</td>
                            <td>{{ $item->credit }}</td>
                        @endif
                        <td>{{ $item->details }}</td>
                        <td>{{ $item->transactiontime }}</td>
                        <td>{{ $item->numbercredited }}</td>
                        <td>{{ $item->numberdebited }}</td>
                        <td>{{ $item->commission }}</td>
                        <td>{{ $item->fx }}</td>

                    </tr>
                @empty
                    <tr>
                        <td colspan="12"></td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>
</div>

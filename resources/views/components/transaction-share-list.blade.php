{{-- <div>
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
</div> --}}

@if (sizeof($transactions) > 0)
    <div class="table-responsive __transactions-table mt-4">
        <table class="table table-sm table-borderless">
            <tr class="table-active">
                <th scope="col" width="5%">#</th>
                <th scope="col" width="15%">Transaction ID</th>
                <th scope="col" width="15%">Date</th>
                <th scope="col" width="20%">Transaction Time</th>
                <th scope="col" width="15%">Amount</th>
                <th scope="col" width="30%">Payee/Payor</th>
            </tr>
            <tbody>
                @foreach ($transactions as $key => $item)
                    <tr class="accordion-toggle collapsed" id="accordion1" data-toggle="collapse"
                        data-parent="#accordion1" href="#collapse{{ $key }}">
                        <th scope="row">{{ $key + 1 }}</th>
                        <td class="__data-transaction-id">
                            <a href="javascript:void(0);" onclick="getData(this.innerHTML)">{{ $item->cashid }}</a>
                        </td>
                        <td>
                            {{ $item->date }}
                        </td>
                        <td>
                            {{ $item->transactiontime }}
                        </td>
                        @if ($accounts == $item->creditfk)
                            <td class="__data-transaction-amount">+ {{ $item->amount }}</td>
                        @elseif ($accounts == $item->debitfk)
                            <td class="text-danger">− {{ $item->amount }}</td>
                        @endif
                        <td type="button" data-toggle="collapse" data-target="#collapseExample" aria-expanded="false"
                            aria-controls="collapseExample" class="d-flex align-items-center justify-content-between">
                            {{ Str::limit($item->details, 18) }}
                            <img src="{{ asset('svgs/ic_arrow-dropdown.svg') }}" alt="">
                        </td>
                    </tr>
                    {{-- Accordion Body as Row --}}
                    <tr class="hide-table-padding">
                        <td></td>
                        <td colspan="5">
                            <div id="collapse{{ $key }}" class="collapse paddingtd">
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
                @endforeach
            </tbody>
        </table>
    </div>
@else
    @component('components.empty-state')
        @slot('title', 'No Transaction Data')
        @slot('caption', 'Looks like there is no recent transaction addition')
    @endcomponent
@endif


@push('scripts')
    <script>
        function getData(id) {
            'use strict'

            var url = `transaction/edit/${id}`

            $.ajax({
                type: "GET",
                url: url,
                success: function(res) {
                    if (res.status == 200) {
                        var data = res.data[0]

                        var numberVar = 0
                        if (data['Numbercredited'] != 0) {
                            numberVar = data['Numbercredited']
                        } else if (data['Numberdebited'] != 0) {
                            numberVar = data['Numberdebited']
                        }
                        //console.log(numberVar)
                        $('input#cashID').val(data['cashID'])
                        $('input#dateVar').val(data['Date'])
                        $('input#transactionTimeVar').val(data['transactiontime'])
                        $('input#fromVar').val(data['AccountName'])
                        $('input#amountVar').val(data['Amount'])
                        $('input#grossVar').val(data['Amount'] - data['commission'])
                        $('input#numberVar').val(numberVar)
                        $('input#detailsVar').val(data['Details'])
                        $('input#segmentVar').val(data['segment'])
                        $('input#fxVar').val(data['fx'])

                        //console.log($('input#cashID').val())
                    }
                }
            })
        }
    </script>
@endpush

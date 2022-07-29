@extends('layout')
@section('title', 'Personal Finance')
@section('content')

    <div class="container">
        <div class="page-title">
            <div class="title">Transactions</div>
            <div class="subtitle">Share Transactions</div>
        </div>
    </div>


    <div class="container-fluid content-page-wrapper pb-5">
        <div class="container px-0">
            <div class="content">
                <div class="row">
                    <div class="col-md-4 col-12 lg:p-40 lg:border-right">
                        <div class="section-title">
                            Add Transactions
                        </div>
                        <div class="section-caption">
                            Input your data transaction here
                        </div>
                        <hr>
                        <form class="needs-validation" novalidate id="formTransaction">
                            <input name="_token" type="hidden" value="{{ csrf_token() }}" />
                            <div class="form-group">
                                <label for="dateVar">Date</label>
                                <input type="date" class="form-control" id="dateVar" name="dateVar" required>
                            </div>
                            <div class="form-group">
                                <label for="transactionTimeVar">Transaction Time</label>
                                <input type="input" class="form-control" id="transactionTimeVar" name="transactionTimeVar"
                                    value="00:00:00">
                            </div>
                            <div class="form-group">
                                <label for="fromVar">Company Name</label>
                                <input type="input" class="form-control autosuggestion" autocomplete="off" id="fromVar"
                                    name="fromVar" data-entry="" data-account="" required>
                            </div>
                            <div class="form-group">
                                <label for="amountVar" class="max-w-max">Net Amount (amount actually paid/received)</label>
                                <input type="number" class="form-control" id="amountVar" name="amountVar" min="0"
                                    step="any" required>
                            </div>
                            <div class="form-group">
                                <label for="catVar">Gross amount</label>
                                <input type="number" class="form-control" id="grossVar" name="grossVar" min="0"
                                    step="any">
                            </div>
                            <div class="form-group">
                                <label for="fullCatVar">Number of shares bought/sold</label>
                                <input type="number" class="form-control" id="numberVar" name="numberVar" required
                                    min="0" step="any">
                            </div>
                            <div class="form-group">
                                <label for="detailsVar">Details</label>
                                <input type="input" class="form-control" id="detailsVar" name="detailsVar">
                            </div>
                            <div class="form-group">
                                <label for="segmentVar">Segment</label>
                                <input type="input" class="form-control" id="segmentVar" name="segmentVar">
                            </div>
                            <div class="form-group">
                                <label for="chequeVar">FX rate for £1</label>
                                <input type="number" class="form-control" id="fxVar" name="fxVar" value="1"
                                    min="0" step="any">
                            </div>
                            <div class="form-group">
                                <div class="custom-control custom-radio custom-control-inline">
                                    <input type="radio" id="debit" value="debit" name="credDeb"
                                        class="custom-control-input">
                                    <label class="custom-control-label" for="debit">Buy</label>
                                </div>
                                <div class="custom-control custom-radio custom-control-inline">
                                    <input type="radio" id="credit" value="credit" name="credDeb" checked
                                        class="custom-control-input">
                                    <label class="custom-control-label" for="credit">Sell</label>
                                </div>
                            </div>

                            {{-- Hidden Inputs --}}
                            <input name="finishDateVar" type="hidden" value="{{ request()->get('finishdate') }}" />
                            <input name="startDateVar" type="hidden" value="{{ request()->get('startdate') }}" />
                            <input name="accountVar" type="hidden" value="{{ request()->get('accounts') }}" />
                            <input name="bankShareVar" type="hidden" value="{{ request()->get('bankshare') }}" />
                            {{-- cashID for update data only --}}
                            <input name="cashID" id="cashID" type="hidden" />

                            <div class="d-flex justify-content-end">
                                <button type="submit" class="btn btn-primary">Submit</button>
                            </div>
                        </form>
                    </div>
                    <div class="col-md-8 col-12 lg:p-40">
                        <div class="statistics d-flex">
                            <div class="card max-w-max p-3">
                                <div class="d-flex align-items-center">
                                    <img src="{{ asset('svgs/ic-credit-card.svg') }}" alt="">
                                    <span class="ml-3 card-title mb-0">Balance today</span>
                                </div>
                                <div class="stat-value">
                                    {{ $balanceToday }}
                                </div>
                            </div>
                        </div>

                        <x-transaction-share-list finishdate="{{ request()->get('finishdate') }}"
                            startdate="{{ request()->get('startdate') }}" accounts="{{ $accounts }}" />

                    </div>

                </div>
            </div>
        </div>

        {{-- Modal --}}
        <div class="modal fade" id="createCompanyModal" tabindex="-1" role="dialog"
            aria-labelledby="exampleModalLabel" aria-hidden="true">
            <div class="modal-dialog" role="document">
                <div class="modal-content" id="modalContent">

                </div>
            </div>
        </div>
    </div>


@endsection

@push('scripts')
    <script>
        var path = "{{ route('autosuggestion') }}";
        $('.autosuggestion').each(function() {
            $this = $(this)
            var divSafe = $("#divSafe").val() == 'on' ? true : false;
            var entry = $this.attr('data-entry');
            var account = $this.attr('data-account');

            var options = {
                json: true,
                script: path + "?entry=" + entry + "&account=" + account + "&divSafe=" + divSafe + "&",
                varname: "input"
            };
            var as_xml = new bsn.AutoSuggest($this.attr("id"), options);
        });

        (function() {
            'use strict';
            window.addEventListener('load', function() {
                var forms = document.getElementsByClassName('needs-validation');
                var validation = Array.prototype.filter.call(forms, function(form) {
                    form.addEventListener('submit', function(event) {
                        if (form.checkValidity() === false) {
                            event.preventDefault();
                            event.stopPropagation();
                        } else {
                            event.preventDefault();
                            var formData = $('#formTransaction').serialize();
                            var url =
                                "{{ action('MainController@saveTransactionShare') }}";
                            var inputCashId = $('input#cashID').val();
                            console.log(inputCashId)
                            $.ajax({
                                type: inputCashId.length != '' ? "PUT" : "POST",
                                url: url,
                                data: $('form').serialize(),
                                success: function(msg) {
                                    if (msg.status == 'success') {
                                        //location.reload();
                                    } else if (msg.status == 'notFound') {
                                        var url =
                                            "{{ action('MainController@createCompany') }}";
                                        $.ajax({
                                            type: "POST",
                                            url: url,
                                            data: formData,
                                            success: function(result) {
                                                $('#createCompanyModal')
                                                    .modal('show');
                                                $("#modalContent").html(
                                                    result)
                                            },
                                            error: function() {
                                                alert(
                                                    "failure when open modal"
                                                );
                                            }
                                        });
                                    } else {
                                        alert(msg.message);
                                    }
                                },
                                error: function() {
                                    alert("failure");
                                }
                            });
                        }
                        form.classList.add('was-validated');
                    }, false);
                });
            }, false);
        })();
    </script>
@endpush

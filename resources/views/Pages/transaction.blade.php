@extends('layout')
@section('title', 'Personal Finance')
@section('content')

    <div class="container">
        <button type="button" class="btn btn-primary" id="liveToastBtn">Show live toast</button>

        <div class="position-fixed bottom-0 right-0 p-3" style="z-index: 5; right: 0; bottom: 0;">
            <div id="liveToast" class="toast hide" role="alert" aria-live="assertive" aria-atomic="true" data-delay="2000">
                <div class="toast-header">
                    <img src="..." class="rounded mr-2" alt="...">
                    <strong class="mr-auto">Bootstrap</strong>
                    <small>11 mins ago</small>
                    <button type="button" class="ml-2 mb-1 close" data-dismiss="toast" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="toast-body">
                    Hello, world! This is a toast message.
                </div>
            </div>

            @push('scripts')
                <script>
                    $('.toast').toast('dispose')
                </script>
            @endpush
        </div>
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
                                <label for="amountVar">Net Amount (amount actually paid/received)</label>
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


                            <div class="d-flex justify-content-end">
                                <button type="submit" class="btn btn-primary ml-auto">Submit</button>
                            </div>
                        </form>
                    </div>
                    <div class="col-md-8 col-12 lg:p-40">
                        <div class="statistics d-flex mb-5">
                            <div class="card max-w-max p-3">
                                <div class="d-flex align-items-center">
                                    <img src="{{ asset('svgs/ic-credit-card.svg') }}" alt="">
                                    <span class="ml-3 card-title mb-0">Balance today</span>
                                </div>
                                <div class="stat-value">
                                    0.00
                                </div>
                            </div>
                        </div>

                        {{-- Empty State --}}
                        <div class="d-flex flex-column align-items-center justify-content-center empty-state-section">
                            <img src="{{ asset('svgs/empty-state.svg') }}" alt="">
                            <div class="title">
                                No Transaction Data
                            </div>
                            <div class="caption">
                                Looks like there is no recent transaction addition
                            </div>
                        </div>
                    </div>
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
                            $.ajax({
                                type: "POST",
                                url: url,
                                data: $('form').serialize(),
                                success: function(msg) {
                                    if (msg.status == 'success') {
                                        location.reload();
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

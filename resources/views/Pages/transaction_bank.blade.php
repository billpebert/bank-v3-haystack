@extends('layout')
@section('title', 'Transaction bank')
@section('content')
    <div class="row">
        <div class="col-md-1">
        </div>
        <div class="col-md-10">
            <div class="py-5 text-center">
                <h2>Add Transaction</h2>
                <p class="lead">Bank statement</p>
            </div>
            <form class="needs-validation" novalidate id="formTransaction">
                <input name="_token" type="hidden" value="{{ csrf_token() }}" />
                <div class="form-row">
                    <div class="col">
                        <div class="form-group">
                            <label for="dateVar">Date</label>
                            <input type="date" class="form-control" id="dateVar" name="dateVar" required>
                        </div>
                    </div>
                    <div class="col">
                        <div class="form-group">
                            <label for="fromVar">To/From</label>
                            <input type="input" class="form-control autosuggestion" autocomplete="off" id="fromVar"
                                name="fromVar" data-entry="" data-account="" required>
                        </div>
                    </div>
                    <div class="col">
                        <div class="form-group">
                            <label for="amountVar">Amount</label>
                            <input type="number" class="form-control autosuggestion" min="0" step="any" autocomplete="off"
                                id="amountVar" name="amountVar" data-entry="Amount" data-account="AcBarclays" required>
                        </div>
                    </div>
                </div>
                <div class="form-row">
                    <div class="col">
                        <div class="form-group">
                            <label for="catVar">Cat</label>
                            <input type="number" class="form-control" id="catVar" name="catVar" min="0" step="any">
                        </div>
                    </div>
                    <div class="col">
                        <div class="form-group">
                            <label for="fullCatVar">Full Cat</label>
                            <input type="input" class="form-control" id="fullCatVar" name="fullCatVar">
                        </div>
                    </div>
                    <div class="col">
                        <div class="form-group">
                            <label for="detailsVar">Details</label>
                            <input type="input" class="form-control autosuggestion" autocomplete="off" id="detailsVar"
                                name="detailsVar" data-entry="Details" data-account="">
                        </div>
                    </div>
                </div>
                <div class="form-row">
                    <div class="col">
                        <div class="form-group">
                            <label for="segmentVar">Segment</label>
                            <input type="input" class="form-control" id="segmentVar" name="segmentVar">
                        </div>
                    </div>
                    <div class="col">
                        <div class="form-group">
                            <label for="chequeVar">Cheque No</label>
                            <input type="number" class="form-control" id="chequeVar" name="chequeVar" min="0" step="any">
                        </div>
                    </div>
                    <div class="col">
                        <div class="form-group">
                            <label for="taxVar">Tax deducted at source (percent)</label>
                            <input type="number" class="form-control" id="taxVar" name="taxVar" min="0" step="any">
                        </div>
                    </div>
                </div>

                @if (utf8_encode($currency[0]->currency) == '£')
                    <input type="hidden" id="fxRate" name="fxRate" value="1" />
                    <input type="hidden" id="fxDetails" name="fxDetails" value="" />
                @else
                    <div class="form-row">
                        <div class="col">
                            <div class="form-group">
                                <label for="fxRate">FX rate</label>
                                <input type="number" class="form-control" value="1" id="fxRate" name="fxRate" min="0"
                                    step="any" required>
                                <input type="hidden" id="fxDetails" name="fxDetails"
                                    value="{{ $currency[0]->currency }}" />
                            </div>
                        </div>
                        <div class="col"></div>
                        <div class="col"></div>
                    </div>
                @endif

                <div class="form-group">
                    <div class="form-check">
                        <input class="form-check-input" type="checkbox" id="divSafe" name="divSafe" checked>
                        <label class="form-check-label" for="divSafe">
                            Dividend safety mode selected?
                        </label>
                    </div>
                </div>

                <div class="form-group">
                    <div class="custom-control custom-radio custom-control-inline">
                        <input type="radio" id="credit" value="debit" name="credDeb" class="custom-control-input">
                        <label class="custom-control-label" for="debit">Credit</label>
                    </div>
                    <div class="custom-control custom-radio custom-control-inline">
                        <input type="radio" id="debit" value="credit" name="credDeb" checked class="custom-control-input">
                        <label class="custom-control-label" for="credit">Debit</label>
                    </div>

                </div>
                <input name="finishDateVar" type="hidden" value="{{ request()->get('finishdate') }}" />
                <input name="startDateVar" type="hidden" value="{{ request()->get('startdate') }}" />
                <input name="accountVar" type="hidden" value="{{ request()->get('accounts') }}" />
                <input name="bankShareVar" type="hidden" value="{{ request()->get('bankshare') }}" />

                <button type="submit" class="btn btn-primary">Submit</button>
                <a href="/" type="button" class="btn btn-secondary">Back to Main menu</a>
            </form>
        </div>
        <div class="col-md-1">
        </div>
    </div>
    <div class="row py-5">

        <div class="col-md-12">
            <x-transaction-bank-list finishdate="{{ request()->get('finishdate') }}"
                startdate="{{ request()->get('startdate') }}" accounts="{{ request()->get('accounts') }}" />
        </div>

    </div>

    <div class="modal fade" id="createAccountModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel"
        aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content" id="modalContent">

            </div>
        </div>
    </div>

    <script>
        var path = "{{ route('autosuggestion') }}";
        $(".autosuggestion").focus(function() {
            $this = $(this)
            var divSafe = $("#divSafe").val() == 'on' ? true : false;
            var entry = $this.attr('data-entry');
            if ($this.attr('id') == 'detailsVar')
                var account = $("#fromVar").val();
            else
                var account = $this.attr('data-account');

            if ($this.attr('id') == 'fromVar') {
                var options = {
                    json: true,
                    script: path + "?entry=" + entry + "&account=" + account + "&divSafe=" + divSafe + "&",
                    varname: "input",
                    cache: false,
                    callback: function(input) {
                        var url =
                            "{{ action('MainController@output') }}";
                        $.ajax({
                            type: "GET",
                            url: url,
                            data: {
                                input: input
                            },
                            success: function(result) {
                                if (result.length) {
                                    $("#detailsVar").val(result[0].details);
                                    $("#amountVar").val(result[0].amount);
                                    $("#catVar").val(result[0].cat);
                                    $("#fullCatVar").val(result[0].fullcat);
                                    $("#taxVar").val(result[0].percent);
                                    $("#segmentVar").val(result[0].segment);
                                    var $radios = $('input:radio[name=credDeb]');

                                    if (input.value == result[0].debit) {
                                        $("#credit").prop('checked', true);
                                    }
                                    if (input.value == result[0].credit) {
                                        $("#debit").prop('checked', true);
                                    }

                                }
                            },
                            error: function() {
                                alert(
                                    "failure when fill form"
                                );
                            }
                        });
                        return;
                    }
                };
            } else {
                var options = {
                    json: true,
                    script: path + "?entry=" + entry + "&account=" + account + "&divSafe=" + divSafe + "&",
                    varname: "input"
                };
            }

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
                                "{{ action('MainController@saveTransactionBank') }}";
                            $.ajax({
                                type: "POST",
                                url: url,
                                data: $('form').serialize(),
                                success: function(msg) {
                                    if (msg.status == 'success') {
                                        location.reload();
                                    } else if (msg.status == 'notFound') {
                                        var url =
                                            "{{ action('MainController@createAccount') }}";
                                        $.ajax({
                                            type: "POST",
                                            url: url,
                                            data: formData,
                                            success: function(result) {
                                                $('#createAccountModal')
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
@endsection

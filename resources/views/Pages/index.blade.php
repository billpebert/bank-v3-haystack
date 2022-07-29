@extends('layout')
@section('title', 'Account class')
@section('content')

    <div class="container">
        <div class="row">
            <div class="col-md-7 offset-md-2">
                <div class="py-5 text-center">
                    <h2>Home page</h2>
                    <p class="lead">Description here ...</p>
                </div>
                <form action="{{ action('MainController@transaction') }}" method="post" class="needs-validation" novalidate>
                    <input name="_token" type="hidden" value="{{ csrf_token() }}" />
                    <div class="form-group">
                        <label for="exampleInputEmail1">Account</label>
                        <select class="form-control" id="accounts" name="accounts">
                            @foreach ($accounts as $item)
                                <option value="{{ $item->AccountID }}">{{ $item->AccountName }}</option>
                            @endforeach
                        </select>
                    </div>
                    <div class="row row-cols-md-2 form-group">
                        <div class="col">
                            <label for="exampleInputPassword1">Statement start date</label>
                            <input type="date" class="form-control w-100" id="startdate" name="startdate" required>
                        </div>
                        <div class="col">
                            <label for="exampleInputPassword1">Statement finish date</label>
                            <input type="date" class="form-control w-100" id="finishdate" name="finishdate" required>
                        </div>
                    </div>

                    <div class="form-group">
                        <div class="custom-control custom-radio custom-control-inline">
                            <input type="radio" id="shares" value="shares" name="bankShare"
                                class="custom-control-input">
                            <label class="custom-control-label" for="shares">Shares transaction</label>
                        </div>
                        <div class="custom-control custom-radio custom-control-inline">
                            <input type="radio" id="bank" name="bankShare" value="bank" checked
                                class="custom-control-input">
                            <label class="custom-control-label" for="bank">Bank statement</label>
                        </div>
                    </div>
                    <button type="submit" class="btn btn-primary btn-block">Submit</button>
                </form>
            </div>
        </div>
    </div>
    <script>
        (function() {
            'use strict';
            window.addEventListener('load', function() {
                var forms = document.getElementsByClassName('needs-validation');
                var validation = Array.prototype.filter.call(forms, function(form) {
                    form.addEventListener('submit', function(event) {
                        if (form.checkValidity() === false) {
                            event.preventDefault();
                            event.stopPropagation();
                        }
                        form.classList.add('was-validated');
                    }, false);
                });
            }, false);
        })();
    </script>
@endsection

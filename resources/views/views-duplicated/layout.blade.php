<!DOCTYPE html>
<html>

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>@yield('title')</title>
    <link href="{{ asset('css/app.css') }}" rel="stylesheet" type="text/css">
    <script src="{{ asset('js/app.js') }}" type="text/javascipt"></script>

    <script src="https://code.jquery.com/jquery-3.5.1.min.js" crossorigin="anonymous"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.5.2/dist/js/bootstrap.min.js" crossorigin="anonymous"></script>
    <script type="text/javascript" src="{{ asset('js/bsn.AutoSuggest_2.1.3.js') }}"></script>
    <link rel="stylesheet" href="css/autosuggest_inquisitor.css" type="text/css" media="screen" charset="utf-8" />

</head>

<body>
    <div class="container">
        @yield('content')
    </div>

</body>

</html>

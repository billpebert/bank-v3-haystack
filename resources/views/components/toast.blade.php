<div class="toast-container" aria-atomic="true">
    <div class="toast" role="alert" aria-live="assertive" data-delay="2500" data-autohide="true">
        <div class="d-flex align-items-center gap-2">
            <img src="{{ asset('svgs/ic-check.svg') }}" alt="">
            <div class="mr-auto" id="__toast-message"></div>
        </div>
    </div>
</div>

@push('scripts')
    <script>
        window.addEventListener('load', function() {
            //If true show toast alert
            if (localStorage.getItem("toast") !== null) {
                document.getElementById('__toast-message').innerHTML = localStorage.getItem("toast")
                $('.toast').addClass('toast-success').toast('show')
                localStorage.removeItem("toast")
            }
        })
    </script>
@endpush

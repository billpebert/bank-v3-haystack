<nav class="navbar navbar-expand-lg navbar-light py-4 container">
    <a class="navbar-brand" href="{{ route('main-page') }}">
        <span>Personal</span>Finance
    </a>
    <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNavAltMarkup"
        aria-controls="navbarNavAltMarkup" aria-expanded="false" aria-label="Toggle navigation">
        <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse justify-content-between" id="navbarNavAltMarkup">
        <div class="navbar-nav mx-lg-auto __navbar-link">
            <a class="nav-link active" href="#">Menu Link</a>
            <a class="nav-link" href="#">Menu Link</a>
            <a class="nav-link" href="#">Menu Link</a>
        </div>
        <div class="navbar-nav">
            <div class="dropdown userprofile">
                <div class="d-flex align-items-center dropdown-toggle" role="button" data-toggle="dropdown"
                    aria-expanded="false">
                    <img src="{{ asset('svgs/avatar-default.svg') }}" alt="">
                    <div class="d-flex flex-column ml-3">
                        <div class="username">Full name</div>
                        <div class="email">username@email.com</div>
                    </div>
                </div>

                <div class="dropdown-menu">
                    <a class="dropdown-item" href="#">Dashboard</a>
                    <a class="dropdown-item" href="#">Settings</a>
                    <a class="dropdown-item" href="#">Sign Out</a>
                </div>
            </div>
        </div>
    </div>
</nav>

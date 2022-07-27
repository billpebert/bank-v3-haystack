<form class="needs-validation" novalidate id="formAccount">
    <div class="modal-header">
        <h5 class="modal-title" id="exampleModalLabel">Add new account </h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
            <span aria-hidden="true">&times;</span>
        </button>
    </div>
    <div class="modal-body">
        <input name="_token" type="hidden" value="{{ csrf_token() }}" />
        <input type="hidden" name="accountVar" value="{{ request()->get('accountVar') }}">
        <input type="hidden" name="bankShareVar" value="{{ request()->get('bankShareVar') }}">
        <input type="hidden" name="startDateVar" value="{{ request()->get('startDateVar') }}">
        <input type="hidden" name="finishDateVar" value="{{ request()->get('finishDateVar') }}">
        <input type="hidden" name="amountVar" value="{{ request()->get('amountVar') }}">
        <input type="hidden" name="catVar" value="{{ request()->get('catVar') }}">
        <input type="hidden" name="taxVar" value="{{ request()->get('taxVar') }}">
        <input type="hidden" name="fxRate" value="{{ request()->get('fxRate') }}">
        <input type="hidden" name="chequeVar" value="{{ request()->get('chequeVar') }}">
        <input type="hidden" name="credDeb" value="{{ request()->get('credDeb') }}">
        <input type="hidden" name="dateVar" value="{{ request()->get('dateVar') }}">
        <input type="hidden" name="detailsVar" value="{{ request()->get('detailsVar') }}">
        <input type="hidden" name="fromVar" value="{{ request()->get('fromVar') }}">
        <input type="hidden" name="fullCatVar" value="{{ request()->get('fullCatVar') }}">
        <input type="hidden" name="segmentVar" value="{{ request()->get('segmentVar') }}">

        <div class="form-row">
            <div class="col">
                <div class="form-group">
                    <label for="dateVar">Choose account type</label>
                    <select class="form-control" id="accountTypeId" name="accountTypeId">
                        @foreach ($accountTypes as $item)
                            <option value="{{ $item->AccountFK }}">{{ $item->AccountTypesName }}</option>
                        @endforeach
                    </select>
                </div>
            </div>
        </div>
    </div>
    </div>
    <div class="modal-footer">
        <button type="submit" class="btn btn-primary">Create Account</button>
        <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
    </div>
</form>
<script>
    $(function() {
        $('#formAccount').on('submit', function(event) {
            event.preventDefault();
            var formData = $('#formAccount').serialize();
            var url = "{{ action('MainController@saveAccount') }}";
            $.ajax({
                type: "POST",
                url: url,
                data: formData,
                success: function(result) {
                    if (result.status == 'success') {
                        location.reload();
                    } else {
                        alert(result.message);
                    }

                },
                error: function(x) {

                    alert("failure when open modal");
                    console.log(x);
                }
            });
        });
    })
</script>

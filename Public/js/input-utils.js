$(() => {
    $('input[name="user"]').on('keydown', function(e) {
        if (e.keyCode == 13) {
            const userId = $(this).val();
            $(this).val($.trim(userId));
        }
    });
});

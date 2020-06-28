$(function () {
    let clipboard = new ClipboardJS('.clipboard');
    clipboard.on('success', (e) => {
        
        let $copySuccessText = $(`span[name="${e.trigger.name}"]`);
        $copySuccessText.text('Copied!');
        let $copyButton = $(`button[name="${e.trigger.name}"]`);
        $copyButton.hover(() => {
            $copySuccessText.text('');
            $copyButton.off();
        });
        
        e.clearSelection();
    });
});

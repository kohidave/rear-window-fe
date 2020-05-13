function loby() {
    const gameId = document.getElementById("join-game-id").value;
    if(localStorage.getItem(gameId)) {
        const startBlock = document.getElementById("start");
        startBlock.style.display = "block";
    } else {
        const joinBlock = document.getElementById("join");
        joinBlock.style.display = "block";
    }
}

function pollForStart() {
    console.log("polling");
    const gameId = $("#join-game-id").val();
    const playerId = localStorage.getItem(gameId);
    $.get(`/game/${gameId}/status`, function(data){
        if(data.start_at) {
            console.log("game started!");
            if(Date.parse(data.end_at) > Date.now()){
                window.location.href = `/game/${gameId}/turn/${playerId}`;
                return;
            } else {
                console.log("Game ended.");
            }
        }
        window.setTimeout(pollForStart, 3000);
    })
}

$(function() {
    if($("#join-game-id").val()) {
        window.setTimeout(pollForStart, 3000);
    }

    $('#join-game').submit(function(e) {
        e.preventDefault();
        $("#join-game-button").prop('disabled', true);
        $("#join-game-button").addClass('is-loading');

        const username = $("#join-game-name").val();
        const gameId = $("#join-game-id").val();
        $.post(`/game/${gameId}/member/${username}`, function(joinData){
            localStorage.setItem(gameId, joinData.user_id);
            window.location.href = `/game/${gameId}`;
        }).fail(function(e){
            console.log(e);
            alert("Oh no, we couldn't join your game.");
        });
    });

    $('#begin-game-button').click(function(){
        const gameId = $("#join-game-id").val();
        const playerId = localStorage.getItem(gameId);
        $("#begin-game-button").prop('disabled', true);
        $("#begin-game-button").addClass('is-loading');
        $.post(`/game/${gameId}/start`, function(joinData){
            window.location.href = `/game/${gameId}/turn/${playerId}`;
        }).fail(function(e){
            console.log(e);
            alert("Oh no, we couldn't join your game.");
        });
    });
});

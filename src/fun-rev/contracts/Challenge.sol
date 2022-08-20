interface ChallengeInterface {
    function solved() external view returns (bool);
}

contract Challenge is ChallengeInterface {
    function solved() public view override returns (bool) {
        return true;
    }
}
